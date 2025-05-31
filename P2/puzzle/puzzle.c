#include <stdio.h>

// 定义最大迷宫的行和列数
#define MAX_N 7
#define MAX_M 7

// 定义方向数组，分别代表上、下、左、右四个方向的移动
int dir[4][2] = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};

// 定义迷宫矩阵和其他全局变量
int maze[MAX_N][MAX_M];
int n, m; // 迷宫的行数和列数
int start_x, start_y, end_x, end_y; // 起点和终点坐标
int route_count = 0; // 记录路径数量

// 深度优先搜索函数
void dfs(int x, int y) {
    // 如果到达终点，增加路线计数
    if (x == end_x && y == end_y) {
        route_count++;        
        return;
    }

    // 临时将当前点标记为走过
    maze[x][y] = 1;

    // 遍历四个方向
    for (int i = 0; i < 4; i++) {
        int new_x = x + dir[i][0];
        int new_y = y + dir[i][1];

        // 判断新位置是否在边界内，且是否是可走的未访问过的点
        if (new_x >= 0 && new_x < n && new_y >= 0 && new_y < m && maze[new_x][new_y] == 0) {
            dfs(new_x, new_y);
        }
    }

    // 回溯时将当前点恢复为未走过
    maze[x][y] = 0;
}

int main() {
    // 读取迷宫的行数和列数
    scanf("%d%d", &n, &m);

    // 读取迷宫矩阵
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            scanf("%d", &maze[i][j]);
        }
    }

    // 读取起点和终点的坐标
    scanf("%d%d", &start_x, &start_y);
    scanf("%d%d", &end_x, &end_y);
    
    // 调整起点和终点的坐标（由于输入从1开始，而数组下标从0开始）
    start_x--; start_y--;
    end_x--; end_y--;

    // 开始深度优先搜索
    dfs(start_x, start_y);

    // 输出逃离路线的数量
    printf("%d\n", route_count);

    return 0;
}
