import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import sys, time, math
import serial
import serial.tools.list_ports
import tkinter as tk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

root = tk.Tk()
xsize=100 #size of x axis
label = tk.Label(root,text="Temperature sensor").grid(column=0, row=0)

try:
    ser = serial.Serial(
        port='COM4', # Change as needed
        baudrate=115200,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_TWO,
        bytesize=serial.EIGHTBITS
    )
    ser.isOpen()
except:
    portlist=list(serial.tools.list_ports.comports())
    print ('Available serial ports:')
    for item in portlist:
       print (item[0])
    sys.exit()






#functions in python defined using def keyword
#define data_gen function
def data_gen():
    t = data_gen.t
    while True:
        t+=1
        strin = ser.readline()
        val = float(strin.decode())
       #val=100.0*math.sin(t*2.0*3.1415/100.0)
        yield t, val #yield works like return, but doesn't clear local variables



def run(data):
    # update the data
    t,y = data
    if t>-1:
        xdata.append(t) #increase the x axis size by t
        ydata.append(y) #increase the y axis size by y
        if t>xsize: # Scroll to the left.
            ax.set_xlim(t-xsize, t)
        line.set_data(xdata, ydata)

    return line,

def on_close_figure(event):
    sys.exit(0)

data_gen.t = -1
fig = plt.figure()
fig.canvas.mpl_connect('close_event', on_close_figure)
canvas = FigureCanvasTkAgg(fig, master=root)
canvas.get_tk_widget().grid(column=0,row=1)

ax = fig.add_subplot(111)
ax.set_xlabel("Time [s]")
ax.set_ylabel("Temperature (C)")

line, = ax.plot([], [], lw=2)
ax.set_ylim(-100, 100)
ax.set_xlim(0, xsize)
ax.grid()
xdata, ydata = [], []

# Important: Although blit=True makes graphing faster, we need blit=False to prevent
# spurious lines to appear when resizing the stripchart.
ani = animation.FuncAnimation(fig, run, data_gen, blit=False, interval=50, repeat=False)

tk.mainloop()

# plt.title('Temperature sensor')
# plt.xlabel('Time (s)')
# plt.ylabel('Temperature (C)')
# plt.show()
