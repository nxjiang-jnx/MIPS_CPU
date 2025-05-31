#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Print the usage information
void usage() {
    printf("Usage: ./csim -s <num> -E <num> -b <num> -t <file>\n");
    printf("Options:\n");
    printf("  -s <num>   Number of set index bits.\n");
    printf("  -E <num>   Number of lines per set.\n");
    printf("  -b <num>   Number of block offset bits.\n");
    printf("  -t <file>  Trace file.\n");
    printf("\n");
    printf("Examples:\n");
    printf("  linux>  ./csim -s 4 -E 1 -b 4 -t traces/yi.trace\n");
}

// Parse the arguments. It will store them into *s, *E, *b, the file.
int parse_cmd(int args, char **argv, int *s, int *E, int *b, char *filename) {
    int flag[4] = {0};
    int flag_num = 4;

    for (int i = 0; i < args; i++) {
        char *str = argv[i];
        if (str[0] == '-') {
            if (str[1] == 's' && i < args) {
                i++;
                sscanf(argv[i], "%d", s);
                flag[0] = 1;
            } else if (str[1] == 'E' && i < args) {
                i++;
                sscanf(argv[i], "%d", E);
                flag[1] = 1;
            } else if (str[1] == 'b' && i < args) {
                i++;
                sscanf(argv[i], "%d", b);
                flag[2] = 1;
            } else if (str[1] == 't' && i < args) {
                i++;
                sscanf(argv[i], "%s", filename);
                flag[3] = 1;
            }
        }
    }
    for (int i = 0; i < flag_num; i++) {
        if (flag[i] == 0) {
            printf("./csim: Missing required command line argument\n");
            usage();
            return 1;
        }
    }
    return 0;
}

// Read and parse one line from the file-ptr trace.
int readline(FILE *trace, int* cache_id, char *op, unsigned long long *address, int *request_length) {
    char str[30];
    if (fgets(str, 30, trace) == NULL) {
        return -1;
    }
    sscanf(str, "%d %c %llx,%d", cache_id, op, address, request_length);

    return 0;
}

#pragma region Structures-And-Functions

// [1/4] Your code for definition of structures, global variables or functions
// 定义 cache 块结构体
typedef struct {
    int valid;              // valid域，记录是否被载入数据
    unsigned long long tag; // 标签位，用于标识 cache 块
    int lru_counter;        // LRU 计数器，用于实现最近最少使用替换原则
} cache_line_t;

// 定义cache组，是由E个cache块组成的数组
typedef cache_line_t* cache_set_t;

// 定义整个cache，它是由多个cache组组成的数组
typedef cache_set_t* cache_t;

// 声明cache变量
cache_t cache;

// 声明全局变量来记录命中、未命中和逐出次数
int hit_count = 0;
int miss_count = 0;
int eviction_count = 0;

// 声明一个全局的时间戳变量，用于LRU计数
int lru_time = 0;// 声明一级缓存（4个）和二级缓存
cache_t L1_caches[4];
cache_t L2_cache;

// 全局统计变量
int l1_hits[4] = {0}, l1_misses[4] = {0}, l1_evictions[4] = {0};
int l2_hits = 0, l2_misses = 0, l2_evictions = 0;

// 初始化缓存
cache_t init_cache(int S, int E) {
    cache_t cache = (cache_t)malloc(S * sizeof(cache_set_t));
    for (int i = 0; i < S; i++) {
        cache[i] = (cache_set_t)malloc(E * sizeof(cache_line_t));
        for (int j = 0; j < E; j++) {
            cache[i][j].valid = 0;
            cache[i][j].tag = 0;
            cache[i][j].lru_counter = 0;
        }
    }
    return cache;
}

// 释放缓存
void free_cache(cache_t cache, int S) {
    for (int i = 0; i < S; i++) {
        free(cache[i]);
    }
    free(cache);
}

// 替换或填补空行
void replace_or_fill(cache_set_t set, int E, unsigned long long tag, int *evictions) {
    int empty_line = -1;
    int lru_line = 0;
    int min_lru = set[0].lru_counter;

    // 寻找空闲行或最近最少使用行
    for (int i = 0; i < E; i++) {
        if (!set[i].valid && empty_line == -1) {
            empty_line = i;
        }
        if (set[i].lru_counter < min_lru) {
            min_lru = set[i].lru_counter;
            lru_line = i;
        }
    }

    // 如果有空闲行，直接填补
    if (empty_line != -1) {
        set[empty_line].valid = 1;
        set[empty_line].tag = tag;
        set[empty_line].lru_counter = lru_time;
    } else {
        // 否则执行替换
        (*evictions)++;
        set[lru_line].tag = tag;
        set[lru_line].lru_counter = lru_time;
    }
}

// 查询缓存
int access_cache(cache_t cache, int S, int E, int b, unsigned long long address, int *hits, int *misses, int *evictions) {
    unsigned long long set_index = (address >> b) & (S - 1);
    unsigned long long tag = address >> (b + __builtin_ctz(S));
    cache_set_t set = cache[set_index];
    lru_time++;

    // 遍历组，判断是否命中
    for (int i = 0; i < E; i++) {
        if (set[i].valid && set[i].tag == tag) {
            // 命中
            set[i].lru_counter = lru_time;
            (*hits)++;
            return 1;
        }
    }

    // 未命中
    (*misses)++;
    return 0;
}

// 处理多级缓存访问逻辑
void handle_cache_access(int cache_id, unsigned long long address, int S1, int E1, int b1, int S2, int E2, int b2) {
    // 一级缓存访问
    if (!access_cache(L1_caches[cache_id], S1, E1, b1, address, &l1_hits[cache_id], &l1_misses[cache_id], &l1_evictions[cache_id])) {
        // 一级缓存未命中，访问二级缓存
        if (!access_cache(L2_cache, S2, E2, b2, address, &l2_hits, &l2_misses, &l2_evictions)) {
            // 二级缓存未命中，模拟从主存加载到二级缓存
            unsigned long long set_index = (address >> b2) & (S2 - 1);
            unsigned long long tag = address >> (b2 + __builtin_ctz(S2));
            replace_or_fill(L2_cache[set_index], E2, tag, &l2_evictions);
        }

        // 将数据写回一级缓存
        unsigned long long set_index = (address >> b1) & (S1 - 1);
        unsigned long long tag = address >> (b1 + __builtin_ctz(S1));
        replace_or_fill(L1_caches[cache_id][set_index], E1, tag, &l1_evictions[cache_id]);
    }
}

#pragma endregion

int main(int args, char **argv) {
    int s, E, b;
    char filename[1024];

    if (parse_cmd(args, argv, &s, &E, &b, filename) != 0) {
        return 0;
    }

    int s1 = 4, E1 = 8, b1 = 4; // 一级缓存配置
    int s2 = 6, E2 = 8, b2 = 6; // 二级缓存配置

    int S1 = 1 << s1, S2 = 1 << s2;

    // 初始化缓存
    for (int i = 0; i < 4; i++) {
        L1_caches[i] = init_cache(S1, E1);
    }
    L2_cache = init_cache(S2, E2);

    // 模拟访问流程
    FILE *trace = fopen(filename, "r");
    int cache_id;
    char op;
    unsigned long long address;
    int request_length;

#pragma region Handle-Trace
    while (readline(trace, &cache_id, &op, &address, &request_length) != -1) {
        if (op == 'I') {
            continue;
        }

        if (op == 'M') {
            l1_hits[cache_id]++;
        }

        handle_cache_access(cache_id, address, S1, E1, b1, S2, E2, b2);       
    }
#pragma endregion

    // 输出统计
    printf("L1 Cache - hits:%d misses:%d evictions:%d\n", l1_hits[0] + l1_hits[1] + l1_hits[2] + l1_hits[3],
                                                             l1_misses[0] + l1_misses[1] + l1_misses[2] + l1_misses[3],
                                                             l1_evictions[0] + l1_evictions[1] + l1_evictions[2] + l1_evictions[3]);
    printf("L2 Cache - hits:%d misses:%d evictions:%d\n", l2_hits, l2_misses, l2_evictions);

    // 释放缓存
    for (int i = 0; i < 4; i++) {
        free_cache(L1_caches[i], S1);
    }
    free_cache(L2_cache, S2);

    return 0;
}
