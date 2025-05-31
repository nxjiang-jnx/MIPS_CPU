#include <stdio.h>

// ��������Թ����к�����
#define MAX_N 7
#define MAX_M 7

// ���巽�����飬�ֱ�����ϡ��¡������ĸ�������ƶ�
int dir[4][2] = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};

// �����Թ����������ȫ�ֱ���
int maze[MAX_N][MAX_M];
int n, m; // �Թ�������������
int start_x, start_y, end_x, end_y; // �����յ�����
int route_count = 0; // ��¼·������

// ���������������
void dfs(int x, int y) {
    // ��������յ㣬����·�߼���
    if (x == end_x && y == end_y) {
        route_count++;        
        return;
    }

    // ��ʱ����ǰ����Ϊ�߹�
    maze[x][y] = 1;

    // �����ĸ�����
    for (int i = 0; i < 4; i++) {
        int new_x = x + dir[i][0];
        int new_y = y + dir[i][1];

        // �ж���λ���Ƿ��ڱ߽��ڣ����Ƿ��ǿ��ߵ�δ���ʹ��ĵ�
        if (new_x >= 0 && new_x < n && new_y >= 0 && new_y < m && maze[new_x][new_y] == 0) {
            dfs(new_x, new_y);
        }
    }

    // ����ʱ����ǰ��ָ�Ϊδ�߹�
    maze[x][y] = 0;
}

int main() {
    // ��ȡ�Թ�������������
    scanf("%d%d", &n, &m);

    // ��ȡ�Թ�����
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            scanf("%d", &maze[i][j]);
        }
    }

    // ��ȡ�����յ������
    scanf("%d%d", &start_x, &start_y);
    scanf("%d%d", &end_x, &end_y);
    
    // ���������յ�����꣨���������1��ʼ���������±��0��ʼ��
    start_x--; start_y--;
    end_x--; end_y--;

    // ��ʼ�����������
    dfs(start_x, start_y);

    // �������·�ߵ�����
    printf("%d\n", route_count);

    return 0;
}
