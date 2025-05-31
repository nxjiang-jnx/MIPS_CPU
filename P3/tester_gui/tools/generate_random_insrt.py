import random
import time

if __name__ == '__main__':
    random.seed(time.time())
    lenth = int(input())
    labelCount = 0;
    file = open("result.asm","w")
    for i in range(lenth):
        tmp = random.randint(0,8)
        
        
        match (tmp):
            case 0:
                file.write(f"add ${random.randint(0,31)},${random.randint(0,31)},${random.randint(0,31)}\n")
            case 1:
                file.write(f"sub ${random.randint(0,31)},${random.randint(0,31)},${random.randint(0,31)}\n")
            case 2:
                file.write(f"ori ${random.randint(0,31)},${random.randint(0,31)},{random.randint(0,65535)}\n")
            case 3:
                file.write(f"lw ${random.randint(0,31)},{random.randint(0,3071)<<2}($0)\n")
            case 4:
                file.write(f"sw ${random.randint(0,31)},{random.randint(0,3071)<<2}($0)\n")
            case 5:
                if(labelCount >= 1):
                    num1 = random.randint(0,31)
                    num2 = random.randint(0,31)
                    while(num2 == num1):
                        num2 = random.randint(0,31)
                    
                    file.write(f"ori ${num1},${num1},{random.randint(0,65535)}\n")
                    file.write(f"beq ${num1},${num2},label{random.randint(0,labelCount-1)}\n")
            case 6:
                file.write(f"lui ${random.randint(0,31)},{random.randint(0,65535)}\n")
            case 7:
                file.write(f"nop\n")
            case 8:
                file.write(f"label{labelCount}:\n")
                labelCount += 1
        
    
    file.close()