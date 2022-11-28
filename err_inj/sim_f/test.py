import os
import time

from mpl_toolkits import mplot3d
import numpy as np
import matplotlib.pyplot as plt

import pandas as pd

MDFile = open("out.md", "w")

start_time = time.time()
os.system('vsim -c -do ../run/vlog.do > vlog.log')
stop_time = time.time()

print("VLOG --- %s seconds ---" % (stop_time - start_time))

REP_CNT = np.linspace(2**10, 2**16, 5).astype(int)
ERR_NUM = np.linspace(50, 500, 5).astype(int)

X , Y = np.meshgrid(REP_CNT, ERR_NUM)

Z = np.zeros((REP_CNT.size, ERR_NUM.size))
Z_time = np.zeros((REP_CNT.size, ERR_NUM.size))

fig = plt.figure()
ax = plt.axes(projection='3d')

for i in range(1,4):
    x = 0
    y = 0
    for REP_CNT_VAL in REP_CNT:
        for ERR_NUM_VAL in ERR_NUM:
            start_time = time.time()
            run_str = "vsim -c test +ERR_INJ_TYPE=err_injector_{0:d} +REP_CNT={1:d} +ERR_NUM={2:d} -do ../run/run.do > err_injector_{0:d}_{1:d}_{2:d}.log".format(i, REP_CNT_VAL, ERR_NUM_VAL)
            os.system(run_str)
            stop_time = time.time()
            exec_time = (stop_time - start_time)
            Z_time[x][y] = exec_time
            print("err_injector_{0:d}_{1:d}_{2:d} execution --- {3:f} seconds ---".format(i, REP_CNT_VAL, ERR_NUM_VAL, exec_time))
            with open(r'err_injector_{0:d}_{1:d}_{2:d}.log'.format(i, REP_CNT_VAL, ERR_NUM_VAL), 'r') as fp:
                lines = fp.readlines()
                for line in lines:
                    if line.find("ErrRMS") != -1:
                        line = line.split(" ")
                        line = line[len(line)-1]
                        Z[x][y] = line
            y += 1
        x += 1
        y = 0

    df = pd.DataFrame(Z, index=REP_CNT, columns=ERR_NUM)
    MDFile.write(df.to_html())
    MDFile.flush()
    df = pd.DataFrame(Z_time, index=REP_CNT, columns=ERR_NUM)
    MDFile.write(df.to_html())
    MDFile.flush()

    ax = plt.axes(projection ='3d') 
    ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap='viridis')
    plt.show()

MDFile.close()
