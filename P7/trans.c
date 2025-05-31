/* transpose function of 32 x 32 */
void transpose_32x32(int M, int N, int A[N][M], int B[M][N]) {
    int i, j, k;
    int a0, a1, a2, a3, a4, a5, a6, a7;
    for (i = 0; i < N; i += 8) {
        for (j = 0; j < M; j += 8) {
            if (i == j) {
                // 对角块特殊处理
                for (k = 0; k < 8; k++) {
                    a0 = A[i+k][j+0];
                    a1 = A[i+k][j+1];
                    a2 = A[i+k][j+2];
                    a3 = A[i+k][j+3];
                    a4 = A[i+k][j+4];
                    a5 = A[i+k][j+5];
                    a6 = A[i+k][j+6];
                    a7 = A[i+k][j+7];

                    B[j+0][i+k] = a0;
                    B[j+1][i+k] = a1;
                    B[j+2][i+k] = a2;
                    B[j+3][i+k] = a3;
                    B[j+4][i+k] = a4;
                    B[j+5][i+k] = a5;
                    B[j+6][i+k] = a6;
                    B[j+7][i+k] = a7;
                }
            } else {
                // 非对角块
                for (k = i; k < i+8; k++) {
                    a0 = A[k][j+0];
                    a1 = A[k][j+1];
                    a2 = A[k][j+2];
                    a3 = A[k][j+3];
                    a4 = A[k][j+4];
                    a5 = A[k][j+5];
                    a6 = A[k][j+6];
                    a7 = A[k][j+7];

                    B[j+0][k] = a0;
                    B[j+1][k] = a1;
                    B[j+2][k] = a2;
                    B[j+3][k] = a3;
                    B[j+4][k] = a4;
                    B[j+5][k] = a5;
                    B[j+6][k] = a6;
                    B[j+7][k] = a7;
                }
            }
        }
    }
}

/* transpose function of 64 x 64 */
void transpose_64x64(int M, int N, int A[N][M], int B[M][N]) {
    int i, j, k;
    int a0, a1, a2, a3, a4, a5, a6, a7;
    for (i = 0; i < N; i += 8) {
        for (j = 0; j < M; j += 8) {
            // 上半部分4行：直接转置前4列和后4列到B中对应位置
            for (k = 0; k < 4; k++) {
                a0 = A[i+k][j+0];
                a1 = A[i+k][j+1];
                a2 = A[i+k][j+2];
                a3 = A[i+k][j+3];
                a4 = A[i+k][j+4];
                a5 = A[i+k][j+5];
                a6 = A[i+k][j+6];
                a7 = A[i+k][j+7];
                
                // 前4列直接转置过去
                B[j+0][i+k] = a0;
                B[j+1][i+k] = a1;
                B[j+2][i+k] = a2;
                B[j+3][i+k] = a3;

                // 后4列先转置到B的右上 4x4 区
                B[j+0][i+k+4] = a4;
                B[j+1][i+k+4] = a5;
                B[j+2][i+k+4] = a6;
                B[j+3][i+k+4] = a7;
            }

            // 处理下半部分4行与中间数据的交换，减少重新加载
            for (k = 0; k < 4; k++) {
                a0 = A[i+4][j+3-k];
                a1 = A[i+5][j+3-k];
                a2 = A[i+6][j+3-k];
                a3 = A[i+7][j+3-k];

                a4 = A[i+4][j+4+k];
                a5 = A[i+5][j+4+k];
                a6 = A[i+6][j+4+k];
                a7 = A[i+7][j+4+k];

                // 交换过程
                B[j+4+k][i+0] = B[j+3-k][i+4];
                B[j+4+k][i+1] = B[j+3-k][i+5];
                B[j+4+k][i+2] = B[j+3-k][i+6];
                B[j+4+k][i+3] = B[j+3-k][i+7];

                B[j+3-k][i+4] = a0;
                B[j+3-k][i+5] = a1;
                B[j+3-k][i+6] = a2;
                B[j+3-k][i+7] = a3;
                B[j+4+k][i+4] = a4;
                B[j+4+k][i+5] = a5;
                B[j+4+k][i+6] = a6;
                B[j+4+k][i+7] = a7;
            }
        }
    }
}

/* transpose function of 61 x 67 */
void transpose_61x67(int M, int N, int A[N][M], int B[M][N]) {
    int i, j, x, y;
    int block_size = 16; 
    for (i = 0; i < N; i += block_size) {
        for (j = 0; j < M; j += block_size) {
            for (x = i; x < i + block_size && x < N; x++) {
                for (y = j; y < j + block_size && y < M; y++) {
                    B[y][x] = A[x][y];
                }
            }
        }
    }
}
