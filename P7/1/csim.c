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

// Print the final string.
void printSummary(int hits, int misses, int evictions) {
    printf("hits:%d misses:%d evictions:%d\n", hits, misses, evictions);
}

// Read and parse one line from the file-ptr trace.
int readline(FILE *trace, char *op, unsigned long long *address, int *request_length) {
    char str[30];
    if (fgets(str, 30, trace) == NULL) {
        return -1;
    }
    sscanf(str, " %c %llx,%d", op, address, request_length);

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
int lru_time = 0;


#pragma endregion

int main(int args, char **argv) {

#pragma region Parse
    int s, E, b;
    char filename[1024];
    if (parse_cmd(args, argv, &s, &E, &b, filename) != 0) {
        return 0;
    }
#pragma endregion

#pragma region Cache-Init

    // [2/4] Your code for initialzing your cache
    // You can use variables s, E and b directly.

    //--------------------------------------//
    // s: set_index位数                     //
    // E: E路组相联，每组E个cache块          //
    // b: 偏移位数                          //
    //-------------------------------------//

    // 计算cache的组数
    int S = 1 << s;     //组数为2的s次方

    // 为cache分配内存
    cache = (cache_t)malloc(S * sizeof(cache_set_t));

    // 初始化cache
    for (int i = 0; i < S; i++) {
        cache[i] = (cache_set_t)malloc(E * sizeof(cache_line_t));
        for (int j = 0; j < E; j++) {
            cache[i][j].valid = 0;      // 初始有效位为0，表示空
            cache[i][j].tag = 0;        // 初始标签为0
            cache[i][j].lru_counter = 0;// 初始LRU计数器为0
        }
    }
    

#pragma endregion

#pragma region Handle-Trace
    FILE *trace = fopen(filename, "r");
    char op;
    unsigned long long address;
    int request_length;

    while (readline(trace, &op, &address, &request_length) != -1) {
        // [3/4] Your code for handling the trace line
        if (op == 'I')
        {
            continue;
        }

        unsigned long long set_index = (address >> b) & ((1 << s) - 1);
        unsigned long long tag = address >> (s + b);

        cache_set_t set = cache[set_index];

        lru_time++;

        int hit = 0;
        int empty_line = -1;
        int lru_line = 0;
        int min_lru = set[0].lru_counter;

        for (int i = 0; i < E; i++)
        {
            if (set[i].valid)
            {
                if (set[i].tag == tag)
                {
                    hit = 1;
                    set[i].lru_counter = lru_time;
                    hit_count++;
                    break;
                }                
            } 
            else if (empty_line = -1)
            {
                empty_line = i;
            }                   
        }
        
        for (int i = 0; i < E; i++)
        {
            if (set[i].lru_counter < min_lru)
            {
                min_lru = set[i].lru_counter;
                lru_line = i;
            }
        }

        if (!hit)
        {
            miss_count++;
            if (empty_line != -1)
            {
                set[empty_line].lru_counter = lru_time;
                set[empty_line].tag = tag;
                set[empty_line].valid = 1;
            }
            else
            {
                eviction_count++;
                set[lru_line].lru_counter = lru_time;
                set[empty_line].tag = tag;
            }
        }
        
        if (op == 'M')
        {
            hit_count++;
        }      
        
    }

#pragma endregion

    // [4/4] Your code to output the hits, misses and evictions
    printSummary(hit_count, miss_count, eviction_count);

    // Maybe you can 'free' your cache here
    for (int i  = 0; i < S; i++) {
        free(cache[i]);
    }
    free(cache);

    return 0;
}

#pragma region stackedVersion

/*begin:

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

// Print the final string.
void printSummary(int hits, int misses, int evictions) {
    printf("hits:%d misses:%d evictions:%d\n", hits, misses, evictions);
}

// Read and parse one line from the file-ptr trace.
int readline(FILE *trace, char *op, unsigned long long *address, int *request_length) {
    char str[30];
    if (fgets(str, 30, trace) == NULL) {
        return -1;
    }
    sscanf(str, " %c %llx,%d", op, address, request_length);

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
int lru_time = 0;

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
void handle_cache_access(unsigned long long address, int S1, int E1, int b1) {
    // 一级缓存访问
    if (!access_cache(cache, S1, E1, b1, address, &hit_count, &miss_count, &eviction_count)) {
        // 将数据写一级缓存
        unsigned long long set_index = (address >> b1) & (S1 - 1);
        unsigned long long tag = address >> (b1 + __builtin_ctz(S1));
        replace_or_fill(cache[set_index], E1, tag, &eviction_count);
    }
}

#pragma endregion

int main(int args, char **argv) {

#pragma region Parse
    int s, E, b;
    char filename[1024];
    if (parse_cmd(args, argv, &s, &E, &b, filename) != 0) {
        return 0;
    }
#pragma endregion

#pragma region Cache-Init

    // [2/4] Your code for initialzing your cache
    // You can use variables s, E and b directly.

    //--------------------------------------//
    // s: set_index位数                     //
    // E: E路组相联，每组E个cache块          //
    // b: 偏移位数                          //
    //-------------------------------------//

    // 计算cache的组数和块的大小  
    int S = 1 << s;     //组数为2的s次方

    // 初始化cache
    cache = init_cache(S, E);
    

#pragma endregion

#pragma region Handle-Trace
    FILE *trace = fopen(filename, "r");
    char op;
    unsigned long long address;
    int request_length;

    while (readline(trace, &op, &address, &request_length) != -1) {
        // [3/4] Your code for handling the trace line
        // 忽略指令加载操作
        if (op == 'I') {
            continue;
        }

        handle_cache_access(address, S, E, b);
        
        // 如果是修改操作，需要额外添加一次命中
        if (op == 'M') {
            hit_count++;
        }
    }

#pragma endregion

    // [4/4] Your code to output the hits, misses and evictions
    printSummary(hit_count, miss_count, eviction_count);

    // Maybe you can 'free' your cache here
    free_cache(cache, S);

    return 0;
}

end */

#pragma endregion

#pragma region selfmadefunctions

/* begin

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

end */

#pragma endregion

#pragma region twolevelcache

/* begin

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int valid;
    unsigned long long tag;
    int lru_counter;
} cache_line_t;

typedef cache_line_t* cache_set_t;
typedef cache_set_t* cache_t;

// 声明一级缓存（4个）和二级缓存
cache_t L1_caches[4];
cache_t L2_cache;

// 全局统计变量
int l1_hits[4] = {0}, l1_misses[4] = {0}, l1_evictions[4] = {0};
int l2_hits = 0, l2_misses = 0, l2_evictions = 0;
int lru_time = 0;

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

int main(int args, char **argv) {
    int s1 = 4, E1 = 2, b1 = 4; // 一级缓存配置
    int s2 = 6, E2 = 4, b2 = 4; // 二级缓存配置

    int S1 = 1 << s1, S2 = 1 << s2;

    // 初始化缓存
    for (int i = 0; i < 4; i++) {
        L1_caches[i] = init_cache(S1, E1);
    }
    L2_cache = init_cache(S2, E2);

    // 模拟访问流程
    unsigned long long address;
    int cache_id = 0; // 示例中假设固定访问cache 0
    while (scanf("%llu", &address) != EOF) {
        handle_cache_access(cache_id, address, S1, E1, b1, S2, E2, b2);
    }

    // 输出统计
    for (int i = 0; i < 4; i++) {
        printf("L1 Cache %d - hits:%d misses:%d evictions:%d\n", i, l1_hits[i], l1_misses[i], l1_evictions[i]);
    }
    printf("L2 Cache - hits:%d misses:%d evictions:%d\n", l2_hits, l2_misses, l2_evictions);

    // 释放缓存
    for (int i = 0; i < 4; i++) {
        free_cache(L1_caches[i], S1);
    }
    free_cache(L2_cache, S2);

    return 0;
}


end */

#pragma endregion
