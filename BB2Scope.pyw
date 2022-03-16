#!/usr/bin/python
#
# BB2Scope GUI: This script reads the data captured by an
# BB2Scope board and displays it using a plot graph
# aimilar to what oscilloscopes do.
# It also allows to send commands to the Gen2BB board.
#
# V2.1 (c) Jesus Calvino-Fraga 2020
# jesusc@ece.ubc.ca
#
import time, serial, serial.tools.list_ports
import tkinter as tk
import matplotlib
import matplotlib.pyplot as plt
import tkinter as Tkinter
from tkinter import *
from tkinter import messagebox as tkMessageBox
from tkinter import simpledialog
from tkinter import filedialog
import numpy as np
matplotlib.use('TkAgg')
from scipy import signal
from scipy.signal import butter,filtfilt
import math

import matplotlib.backends.backend_tkagg as tkagg
try:
    from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg # NavigationToolbar2TkAgg is deprecated in newer versions of matplotlib
except:
    from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
    
# implement the default mpl key bindings
from matplotlib.backend_bases import key_press_handler
from matplotlib.figure import Figure
from os import path, access, R_OK, W_OK

def NexOption (x_var, x_var_list):
    current_sel = x_var_list.index(x_var.get())
    current_sel = current_sel+1
    if current_sel >= len(x_var_list):
        current_sel=0
    x_var.set(x_var_list[current_sel])

def PrevOption (x_var, x_var_list):
    current_sel = x_var_list.index(x_var.get())
    current_sel = current_sel-1
    if current_sel < 0:
        current_sel=len(x_var_list)-1
    x_var.set(x_var_list[current_sel])

#------------------------------------------------------------------------------------------
# Implementation of keyboard shortcuts
def key(event):
    global Mode_var, Channel_var, Edge_var, Rate_var, Click_var
    global Mode_var_list, Channel_var_list, Edge_var_list, Rate_var_list, Click_var_list
    global Math_var, Gen_Cmmd_var, Display_var, CH1G_var, CH1M_var, CH2G_var, CH2M_var
    global Math_var_list, Gen_Cmmd_var_list, Display_var_list, CH1G_var_list, CH1M_var_list, CH2G_var_list, CH2M_var_list
    global CH1_on, CH2_on, Cursor1_on, Cursor2_on, Freq_on, Vtrig_on, Math_on
    global CH1_Inv_on, CH2_Inv_on, CH1_DSP_on, CH2_DSP_on
    global Entry1, Gen_Cmd, top, moving_average_factor, dynamic_factor
    global CH1_zero_val, CH2_zero_val, CH1_zero, CH2_zero
    global V_Trigger, line_trigger, Top_X, sampling_frequency
    global cursor1_x, cursor1_y, cursor2_x, cursor2_y
    global Label_type

    # -------------
    if (event.char>='0' and event.char<='9'):
        if top.focus_get() != Entry1:
             Entry1.focus()
             Entry1.insert(END, str(event.char))
    # -------------
    if event.char=='a':
        NexOption(Mode_var, Mode_var_list)
    elif event.char=='A':
        PrevOption(Mode_var, Mode_var_list)
    # -------------
    elif event.char=='b':
        NexOption(Channel_var, Channel_var_list)
    elif event.char=='B':
        PrevOption(Channel_var, Channel_var_list)
    # -------------
    elif event.char=='c':
        NexOption(Edge_var, Edge_var_list)
    elif event.char=='C':
        PrevOption(Edge_var, Edge_var_list)
    # -------------
    elif event.char=='d':
        NexOption(Rate_var, Rate_var_list)
    elif event.char=='D':
        PrevOption(Rate_var, Rate_var_list)
    # -------------
    elif event.char=='e':
        NexOption(Click_var, Click_var_list)
    elif event.char=='E':
        PrevOption(Click_var, Click_var_list)
    # -------------
    elif event.char=='f':
        NexOption(Math_var, Math_var_list)
    elif event.char=='F':
        PrevOption(Math_var, Math_var_list)
    # -------------
    elif event.char=='g':
        NexOption(Gen_Cmmd_var, Gen_Cmmd_var_list)
    elif event.char=='G':
        PrevOption(Gen_Cmmd_var, Gen_Cmmd_var_list)
    # -------------
    elif event.char=='h':
        NexOption(Display_var, Display_var_list)
    elif event.char=='H':
        PrevOption(Display_var, Display_var_list)
    # -------------
    elif event.char=='i':
        NexOption(CH1G_var, CH1G_var_list)
    elif event.char=='I':
        PrevOption(CH1G_var, CH1G_var_list)
    # -------------
    elif event.char=='j':
        NexOption(CH1M_var, CH1M_var_list)
    elif event.char=='J':
        PrevOption(CH1M_var, CH1M_var_list)
    # -------------
    elif event.char=='k':
        NexOption(CH2G_var, CH2G_var_list)
    elif event.char=='K':
        PrevOption(CH2G_var, CH2G_var_list)
    # -------------
    elif event.char=='l':
        NexOption(CH2M_var, CH2M_var_list)
    elif event.char=='L':
        PrevOption(CH2M_var, CH2M_var_list)
    # -------------
    elif event.char=='z':
        Label_type=Label_type+1
        if Label_type>4:
            Label_type=0
    # -------------           
    elif event.char=='Z':
        Label_type=Label_type-1
        if Label_type<0:
            Label_type=4
    # -------------
    elif event.char=='~':
        CH1_Inv_on.set(not CH1_Inv_on.get())
    # -------------
    elif event.char=='!':
        CH1_DSP_on.set(not CH1_DSP_on.get())
    # -------------
    elif event.char=='@':
        CH2_Inv_on.set(not CH2_Inv_on.get())
    # -------------
    elif event.char=='#':
        CH2_DSP_on.set(not CH2_DSP_on.get())
    # -------------
    elif event.char=='$':
        CH1_on.set(not CH1_on.get())
    # -------------
    elif event.char=='%':
        CH2_on.set(not CH2_on.get())
    # -------------
    elif event.char=='^':
        Cursor1_on.set(not Cursor1_on.get())
    # -------------
    elif event.char=='&':
        Cursor2_on.set(not Cursor2_on.get())
    # -------------
    elif event.char=='*':
        Freq_on.set(not Freq_on.get())
    # -------------
    elif event.char=='(':
        Vtrig_on.set(not Vtrig_on.get())
    # -------------
    elif event.char==')':
        Math_on.set(not Math_on.get())
    # -------------
    elif event.char=='x' or event.char=='X':
        Just_Exit()
    # -------------
    elif event.char=='s' or event.char=='S':
        Run_Stop_Callback()
    # -------------
    elif event.char=='z' or event.char=='Z':
        GeneratorCommand()
    # -------------
    elif event.char=='?':
        tkMessageBox.showinfo(\
            "Keyboard Shortcuts",
            "a: Trigger mode\n"\
            "b: Trigger source\n"\
            "c: Trigger edge\n"\
            "d, D: Capture rate\n"\
            "e, E: Click on plots\n"\
            "f, F: Math\n"\
            "g, G: Generator command\n"\
            "h, H: Display mode\n"\
            "i, I: CH1 (V/DIV)\n"\
            "j, J: CH1 mode\n"\
            "k, K: CH2 (V/DIV)\n"\
            "l, L: CH2 mode\n"\
            "z, Z: On-screen display type\n"\
            "~: Invert CH1\n"\
            "!: DSP CH1\n"\
            "@: Invert CH2\n"\
            "#: DSP CH2\n"\
            "$: CH1 show/hide\n"\
            "%: CH2 show/hide\n"\
            "^: Cursor 1 show/hide\n"\
            "&: Cursor 2 show/hide\n"\
            "*: Frequency & max show/hide\n"\
            "(: Trigger voltage show/hide\n"\
            "): Math show/hide\n"\
            "+: Save configuration to file\n"\
            "=: Read configuration from file\n"\
            )
    # -------------
    elif event.char=='+':
        f = filedialog.asksaveasfile(title='Write configuration file', mode='w', defaultextension=".txt",  filetypes=(("txt files","*.txt"),("all files","*.*")))
        if not f:
            return
        try:
            f.write("BB2Scope configuration file\n")
            f.write(Mode_var.get()+"\n")
            f.write(Channel_var.get()+"\n")
            f.write(Edge_var.get()+"\n")
            f.write(Rate_var.get()+"\n")
            f.write(Click_var.get()+"\n")

            f.write(Math_var.get()+"\n")
            f.write(Gen_Cmmd_var.get()+"\n")
            f.write(Display_var.get()+"\n")
            f.write(CH1G_var.get()+"\n")
            f.write(CH1M_var.get()+"\n")
            f.write(CH2G_var.get()+"\n")
            f.write(CH2M_var.get()+"\n")
      
            f.write(str(CH1_on.get())+"\n")
            f.write(str(CH2_on.get())+"\n")
            f.write(str(Cursor1_on.get())+"\n")
            f.write(str(Cursor2_on.get())+"\n")
            f.write(str(Freq_on.get())+"\n")
            f.write(str(Vtrig_on.get())+"\n")
            f.write(str(Math_on.get())+"\n")
            
            f.write(str(CH1_Inv_on.get())+"\n")
            f.write(str(CH2_Inv_on.get())+"\n")
            f.write(str(CH1_DSP_on.get())+"\n")
            f.write(str(CH2_DSP_on.get())+"\n")

            f.write(str(CH1_zero_val)+"\n")
            f.write(str(CH2_zero_val)+"\n")
            f.write(str(V_Trigger)+"\n")
            f.write(str(cursor1_x)+"\n")
            f.write(str(cursor1_y)+"\n")
            f.write(str(cursor2_x)+"\n")
            f.write(str(cursor2_y)+"\n")

        except:
            f.close()
            tkMessageBox.showwarning("Writing file", "There was a problem writing the configuration file.\n");
        
        f.close()
    # -------------
    elif event.char=='=':
        f = filedialog.askopenfile(title='Read configuration file',  mode='r', defaultextension=".txt",  filetypes=(("txt files","*.txt"),("all files","*.*")))
        if not f:
            return None

        Lines = f.readlines()
    
        if Lines[0].strip() != "BB2Scope configuration file":
            tkMessageBox.showwarning("Read file", "Not a configuration file\n");
        else:
            try:
                Mode_var.set(Lines[1].strip())
                Channel_var.set(Lines[2].strip())
                Edge_var.set(Lines[3].strip())
                Rate_var.set(Lines[4].strip())
                Click_var.set(Lines[5].strip())

                Math_var.set(Lines[6].strip())
                Gen_Cmmd_var.set(Lines[7].strip())
                Display_var.set(Lines[8].strip())
                CH1G_var.set(Lines[9].strip())
                CH1M_var.set(Lines[10].strip())
                CH2G_var.set(Lines[11].strip())
                CH2M_var.set(Lines[12].strip())

                CH1_on.set(Lines[13].strip()=='True')
                CH2_on.set(Lines[14].strip()=='True')
                Cursor1_on.set(Lines[15].strip()=='True')
                Cursor2_on.set(Lines[16].strip()=='True')
                Freq_on.set(Lines[17].strip()=='True')
                Vtrig_on.set(Lines[18].strip()=='True')
                Math_on.set(Lines[19].strip()=='True')
                
                CH1_Inv_on.set(Lines[20].strip()=='True')
                CH2_Inv_on.set(Lines[21].strip()=='True')
                CH1_DSP_on.set(Lines[22].strip()=='True')
                CH2_DSP_on.set(Lines[23].strip()=='True')

                CH1_zero_val=float(Lines[24].strip())
                CH1_zero.set_ydata(CH1_zero_val)
                CH2_zero_val=float(Lines[25].strip())
                CH2_zero.set_ydata(CH2_zero_val)

                V_Trigger=float(Lines[26].strip())
                line_trigger.set_data([0, Top_X/sampling_frequency], [V_Trigger, V_Trigger])           

                cursor1_x=float(Lines[27].strip())
                cursor1_y=float(Lines[28].strip())
                cursor2_x=float(Lines[29].strip())
                cursor2_y=float(Lines[30].strip())
                UpdateLabels()
                
            except:
                f.close()
                tkMessageBox.showwarning("Read file", "There was a problem loading a configuration file.\n");
        f.close()
       
    # -------------
    elif event.char=='/': # keep this undocumented for now
        try:
            mystr=Entry1.get().replace("/", "")
            Entry1.delete(0, END)
            Entry1.insert(0, mystr)
            moving_average_factor=float(mystr)
            if moving_average_factor > 1.0:
                moving_average_factor=1.0
            if moving_average_factor < 0.01:
                moving_average_factor=0.01
            dynamic_factor=1.0
        except:
            print("Don't know how to convert " + mystr + " to float")
    # -------------
    #else:
    #    print(str(event.char))


#------------------------------------------------------------------------------------------   
# Lifted from:
# https://stackoverflow.com/questions/3221956/how-do-i-display-tooltips-in-tkinter
""" tk_ToolTip_class101.py
gives a Tkinter widget a tooltip as the mouse is above the widget
tested with Python27 and Python34  by  vegaseat  09sep2014
www.daniweb.com/programming/software-development/code/484591/a-tooltip-class-for-tkinter

Modified to include a delay time by Victor Zaccardo, 25mar16
"""

class CreateToolTip(object):
    """
    create a tooltip for a given widget
    """
    def __init__(self, widget, text='widget info'):
        self.waittime = 500     #miliseconds
        self.wraplength = 180   #pixels
        self.widget = widget
        self.text = text
        self.widget.bind("<Enter>", self.enter)
        self.widget.bind("<Leave>", self.leave)
        self.widget.bind("<ButtonPress>", self.leave)
        self.id = None
        self.tw = None

    def enter(self, event=None):
        self.schedule()

    def leave(self, event=None):
        self.unschedule()
        self.hidetip()

    def schedule(self):
        self.unschedule()
        self.id = self.widget.after(self.waittime, self.showtip)

    def unschedule(self):
        id = self.id
        self.id = None
        if id:
            self.widget.after_cancel(id)

    def showtip(self, event=None):
        x = y = 0
        x, y, cx, cy = self.widget.bbox("insert")
        x += self.widget.winfo_rootx() + 25
        y += self.widget.winfo_rooty() + 20
        # creates a toplevel window
        self.tw = tk.Toplevel(self.widget)
        # Leaves only the label and removes the app window
        self.tw.wm_overrideredirect(True)
        self.tw.wm_geometry("+%d+%d" % (x, y))
        label = tk.Label(self.tw, text=self.text, justify='left',
                       background="#ffffff", relief='solid', borderwidth=1,
                       wraplength = self.wraplength)
        label.pack(ipadx=1)

    def hidetip(self):
        tw = self.tw
        self.tw= None
        if tw:
            tw.destroy()

#------------------------------------------------------------------------------------------   
def GeneratorCommand():
    global Gen_Cmmd_var, Entry1

    try:  
        ser.write('F'.encode('UTF8'))

        Gen_Cmmd=Gen_Cmmd_var.get()
        
        if Gen_Cmmd=='Out1 Amplitude':
            ser.write('A1'.encode('UTF8'))
            ser.write(Entry1.get().encode('UTF8'))
        elif Gen_Cmmd=='Out2 Amplitude':
            ser.write('A2'.encode('UTF8'))
            ser.write(Entry1.get().encode('UTF8'))
        elif Gen_Cmmd=='Out1 Offset':
            ser.write('O1'.encode('UTF8'))
            ser.write(Entry1.get().encode('UTF8'))
        elif Gen_Cmmd=='Out2 Offset':
            ser.write('O2'.encode('UTF8'))
            ser.write(Entry1.get().encode('UTF8'))
        elif Gen_Cmmd=='Frequency':
            ser.write('F'.encode('UTF8'))
            ser.write(Entry1.get().encode('UTF8'))
        elif Gen_Cmmd=='Phase':
            ser.write('P'.encode('UTF8'))
            ser.write(Entry1.get().encode('UTF8'))
        elif Gen_Cmmd=='Out1 Sine':
            ser.write('S1'.encode('UTF8'))
        elif Gen_Cmmd=='Out2 Sine':
            ser.write('S2'.encode('UTF8'))
        elif Gen_Cmmd=='Out1 Square':
            ser.write('Q1'.encode('UTF8'))
        elif Gen_Cmmd=='Out2 Square':
            ser.write('Q2'.encode('UTF8'))
        elif Gen_Cmmd=='Out1 Triangle':
            ser.write('T1'.encode('UTF8'))
        elif Gen_Cmmd=='Out2 Triangle':
            ser.write('T2'.encode('UTF8'))
        elif Gen_Cmmd=='Out1 Ramp':
            ser.write('R1'.encode('UTF8'))
        elif Gen_Cmmd=='Out2 Ramp':      
            ser.write('R2'.encode('UTF8'))
        elif Gen_Cmmd=='Save':
            ser.write('Y'.encode('UTF8'))
        elif Gen_Cmmd=='Restore':
            ser.write('X'.encode('UTF8'))
        elif Gen_Cmmd=='On':
            ser.write('E1'.encode('UTF8'))
        elif Gen_Cmmd=='Off':
            ser.write('E0'.encode('UTF8'))
        elif Gen_Cmmd=='None': # Free form command for expert users.
            ser.write(Entry1.get().encode('UTF8'))
        ser.write('$'.encode('UTF8'))
        
        time.sleep(0.2)
    except:
        print('Exception in GeneratorCommand()')
    Dialoging=0

#------------------------------------------------------------------------------------------   
def on_enter(event):
    GeneratorCommand()
    
#------------------------------------------------------------------------------------------   
def Just_Exit():
    if tkMessageBox.askyesno("Exit", "Do you want to exit the program?"):
        top.quit()
        top.destroy()
        try:
            ser.close()
        except:
            dummy=0

#------------------------------------------------------------------------------------------   
def Run_Stop_Callback():
    global Run_Stop_Var, Run_Stop_Button
    
    if Run_Stop_Var.get()=='Run':
        Run_Stop_Button.configure(bg = "red")
        Run_Stop_Var.set('Stop')
    else:
        Run_Stop_Button.configure(bg = "green")
        Run_Stop_Var.set('Run')

#------------------------------------------------------------------------------------------   
def ResetCnt_Callback(event):
    global LastClickCnt
    LastClickCnt=0
    
#------------------------------------------------------------------------------------------   
def crc16_ccitt(crc, data):
    msb = crc >> 8
    lsb = crc & 255
    for c in data:
        x = c ^ msb
        x ^= (x >> 4)
        msb = (lsb ^ (x >> 3) ^ (x << 4)) & 255
        lsb = (x ^ (x << 5)) & 255
    return (msb << 8) + lsb

#------------------------------------------------------------------------------------------   
def UpdateLabels():
    global cursor1_x, cursor1_y, line_cursor1_x, line_cursor1_y
    global cursor2_x, cursor2_y, line_cursor2_x, line_cursor2_y
    global CH1G, CH2G
    global sampling_frequency
    global CH1G_var, CH2G_var
    global CH1_on, CH2_on

    try:
        Label1_val.set('dV=(' + str(round((cursor2_y - cursor1_y)*CH1G, 3)) + ', ' + str(round((cursor2_y - cursor1_y)*CH2G, 2)) + ')V')
        Label2_val.set('dt=' + str(round(cursor2_x - cursor1_x, 4)) + 'ms')
        if abs(cursor2_x - cursor1_x)>0:
            Label3_val.set('f=' + str(round(1.0e3/abs(cursor2_x - cursor1_x), 2)) + 'Hz')
        else:
            Label3_val.set('f=???')
        line_cursor1_x.set_data([cursor1_x, cursor1_x], [-4, 4])
        line_cursor1_y.set_data([0.0, Top_X/sampling_frequency], [cursor1_y, cursor1_y])
        line_cursor2_x.set_data([cursor2_x, cursor2_x], [-4, 4])
        line_cursor2_y.set_data([0.0, Top_X/sampling_frequency], [cursor2_y, cursor2_y])

        if CH1_on.get() and CH2_on.get():
            s="CH1:%sV/Div, CH2:%sV/Div" % (CH1G_var.get(), CH2G_var.get())
        elif CH1_on.get():
            s="CH1:%sV/Div" % (CH1G_var.get())
        elif CH2_on.get():
            s="CH2:%sV/Div" % (CH2G_var.get())
        else:
            s="Div"
        ax.set_ylabel(s, fontsize=10)
        
    except:
        #print('Exception in UpdateLabels()\n')
        return

#------------------------------------------------------------------------------------------   
def onclick(event):
    global V_Trigger, line_trigger
    global sampling_frequency
    global Click_var
    global cursor1_x, cursor1_y, line_cursor1_x, line_cursor1_y
    global cursor2_x, cursor2_y, line_cursor2_x, line_cursor2_y
    global Label1_val, Label2_val, Label3_val, Label5_val
    global CH1_zero_val, CH2_zero_val
    global LastClickCnt, Click_var

    LastClickCnt=0
    
    try:
        #print('%s click: button=%d, x=%d, y=%d, xdata=%f, ydata=%f' %
        #      ('double' if event.dblclick else 'single', event.button,
        #       event.x, event.y, event.xdata, event.ydata)) # for testing
        if Click_var.get()=='V trigg':
            V_Trigger=event.ydata
            line_trigger.set_data([0, Top_X/sampling_frequency], [V_Trigger, V_Trigger])           
        elif Click_var.get()=='Cursor 1':
            cursor1_x=event.xdata
            cursor1_y=event.ydata
            UpdateLabels()
        elif Click_var.get()=='Cursor 2':
            cursor2_x=event.xdata
            cursor2_y=event.ydata
            UpdateLabels()
        elif Click_var.get()=='Zero CH1':
            CH1_zero_val=event.ydata
            CH1_zero.set_ydata(CH1_zero_val)
        elif Click_var.get()=='Zero CH2':
            CH2_zero_val=event.ydata
            CH2_zero.set_ydata(CH2_zero_val)

    except:
        #Label5_val.set('onclick() exception')
        #print('onclick() exception')
        return

#------------------------------------------------------------------------------------------
#This overdrives the function that displays the x-y coordinates besides the matlib plot toolbar
def format_coord(x, y):
    global CH1_on, CH2_on
    global CH1G, CH2G
    global Display_var

    try:
        if Display_var.get()=='YT':
            if CH1_on.get() and CH2_on.get():
                return 'CH1=%1.2fV, CH2=%1.2fV, t=%1.2fms' % (y*CH1G, y*CH2G, x)
            elif CH1_on.get():
                return 'CH1=%1.2fV, t=%1.2fms' % (y*CH1G, x)
            elif CH2_on.get():
                return 'CH2=%1.2fV, t=%1.2fms' % (y*CH2G, x)
            else:
                return 'x=%1.4f, y=%1.4f'%(x, y)
        else:
            if Display_var.get()=='XY':
                return 'x=%1.2fV, y=%1.2fV' % (x*CH1G, y*CH2G)
            if Display_var.get()=='YX':
                return 'x=%1.2fV, y=%1.2fV' % (x*CH2G, y*CH1G)
            else:
                return 'x=%1.4f, y=%1.4f'%(x, y)
    except:
        return 'x=%1.4f, y=%1.4f'%(x, y)

#------------------------------------------------------------------------------------------   
def Init_GUI():
    global top, sec, line_ch1, line_ch2, line_trigger, canvas
    global ax, screen_msg
    global Mode_var, Channel_var, Edge_var, Rate_var, Click_var
    global Mode_var_list, Channel_var_list, Edge_var_list, Rate_var_list, Click_var_list
    global V_Trigger
    global ch1, ch2
    global average_ch1, average_ch2, moving_average_factor
    global cursor1_x, cursor1_y, line_cursor1_x, line_cursor1_y
    global cursor2_x, cursor2_y, line_cursor2_x, line_cursor2_y
    global Label1_val, Label2_val, Label3_val, Label4_val, Label5_val
    global sampling_frequency, Num_Samples, Top_X, Ref_Voltage
    global Run_Stop_Var, Display_var
    global CH1_on, CH2_on, Cursor1_on, Cursor2_on, Freq_on, Vtrig_on
    global Math_on, Math_var
    global Run_Stop_Button
    global line_XY, line_Math
    global CH1G_var, CH2G_var, CH1G, CH2G
    global CH1M_var, CH2M_var, CH1M, CH2M
    global CH1_zero, CH2_zero
    global CH1_zero_val, CH2_zero_val
    global Gen_Cmmd_var, Entry1, Gen_Cmd
    global CH1_Inv_on, CH2_Inv_on, CH1_DSP_on, CH2_DSP_on
    global LastClickCnt, Click_var
    global Math_var_list, Gen_Cmmd_var_list, Display_var_list, CH1G_var_list, CH1M_var_list, CH2G_var_list, CH2M_var_list
    global popupMenu1, ChkButton1

    LastClickCnt=0
    
    top = Tk()
    top.resizable(1,1)
    top.title("BB2SCOPE V2.1 by Jesus Calvino-Fraga")
    top.bind("<Key>", key)

    f = Figure(figsize=(6, 4), dpi=120)
    f.patch.set_facecolor('white')
    ax = f.add_subplot(111)
    ax.format_coord = format_coord

    # The CH1/CH2 plot traces
    line_ch1, = ax.plot([], [], 'y-', linewidth=2)
    line_ch2, = ax.plot([], [], 'b-', linewidth=2)

    # Math and XY traces
    line_XY, = ax.plot([], [], 'g-', linewidth=2)
    line_Math, = ax.plot([], [], 'r-', linewidth=2)   

    # Set up the offset/zero markers on the left/right side of the plot for CH1 and CH2
    CH1_zero_val=0
    CH2_zero_val=0
    CH1_zero, = ax.plot([0], [CH1_zero_val], 'y>', markersize=14)
    CH2_zero, = ax.plot([0], [CH2_zero_val], 'b>', markersize=10)
    
    # The trigger point line
    line_trigger, = ax.plot([], [], 'c:', linewidth=1)
    ax.set_ylabel('Div', fontsize=10)
    ax.set_xlabel('t (ms)', fontsize=10)
   
    # Configure the cursors
    cursor1_x=0.25
    cursor1_y=1.0
    cursor2_x=0.35
    cursor2_y=0.5
    line_cursor1_x, =  ax.plot([cursor1_x, cursor1_x], [-4, 4], 'r--', linewidth=1)
    line_cursor1_y, =  ax.plot([0.0, Top_X/sampling_frequency], [cursor1_y, cursor1_y], 'r--', linewidth=1)
    line_cursor2_x, =  ax.plot([cursor2_x, cursor2_x], [-4, 4], 'g--', linewidth=1)
    line_cursor2_y, =  ax.plot([0.0, Top_X/sampling_frequency], [cursor2_y, cursor2_y], 'g--', linewidth=1)

    screen_msg=ax.text(50/sampling_frequency, 4.5, "???", fontsize=10)
    ax.set_xlim(0, Top_X/sampling_frequency)
    ax.set_ylim(-4, 4)
    x = np.arange(0.0, Num_Samples, 1.0)
    x = x / sampling_frequency
    ch1 = np.zeros(Num_Samples)
    ch2 = np.zeros(Num_Samples)
    line_ch1.set_data(x, ch1)
    line_ch2.set_data(x, ch2)
    line_Math.set_data(x, ch1-ch2)
    line_XY.set_data(ch1, ch2)

    average_ch1=ch1
    average_ch2=ch2

    # Default trigger level
    V_Trigger=0.0
    line_trigger.set_data([0, Top_X/sampling_frequency], [V_Trigger, V_Trigger])

    # Draw the grid
    ax.grid()
    ax.set_xticks(np.arange(0, Top_X/sampling_frequency, 50/sampling_frequency))
    ax.set_yticks(np.arange(-4, 4, 1.0))
    # Change the fontsize of minor/major ticks label 
    ax.tick_params(axis='both', which='major', labelsize=10)
    ax.tick_params(axis='both', which='minor', labelsize=10)

    # Adjust the margins of the plot.  User can readjust them using plot toolbar
    f.subplots_adjust(left=0.1, right=0.97, top=0.9, bottom=0.1)

    # Get the canvas associated with the plot so we can adjust it on tkinter
    canvas = FigureCanvasTkAgg(f, master=top)
    cid = canvas.mpl_connect('button_press_event', onclick)
    canvas.draw()
    canvas.get_tk_widget().grid(row=2, column=0, columnspan=6, rowspan=9, sticky="nsew")

    # https://stackoverflow.com/questions/12913854/displaying-matplotlib-navigation-toolbar-in-tkinter-via-grid
    toolbarFrame = Frame(master=top)
    toolbarFrame.grid(row=0, column=0, columnspan=5, sticky=W)
    try:
        toolbar = NavigationToolbar2TkAgg(canvas, toolbarFrame) # deprecated in newer versions of matplotlib
    except:
        toolbar = NavigationToolbar2Tk(canvas, toolbarFrame)

    Label1_val = StringVar()
    Label1=Label(top, textvariable=Label1_val)
    Label1.grid(row = 1, column = 0)
    Label1_val.set('dy=' + str(round(cursor2_y - cursor1_y, 2)))
    Label1.config(width=15)
   
    Label2_val = StringVar()
    Label2=Label(top, textvariable=Label2_val)
    Label2.grid(row = 1, column = 1)
    Label2_val.set('dt=' + str(round(cursor2_x - cursor1_x, 2)) + 'ms')

    Label3_val = StringVar()
    Label3=Label(top, textvariable=Label3_val)
    Label3.grid(row = 1, column = 2)
    if abs(cursor2_x - cursor1_x)>0:
        Label3_val.set('f=' + str(round(1.0e3/abs(cursor2_x - cursor1_x), 2)) + 'Hz')
    else:
        Label3_val.set('f=???')

    Label4_val = StringVar()
    Label4=Label(top, textvariable=Label4_val)
    Label4.grid(row = 1, column = 5, columnspan=2, sticky=W)
    Label4_val.set('COM?')

    # This label is used for status/debug messages
    Label5_val = StringVar()
    Label5=Label(top, textvariable=Label5_val)
    Label5.grid(row = 1, column = 3, columnspan=2, sticky=W)
    Label5_val.set('')

    Mode_var_list= ['Auto', 'Normal', 'Auto Average']
    Mode_var = StringVar()
    Mode_var.set('Auto')
    popupMenu1 = OptionMenu(top, Mode_var, *Mode_var_list)
    Label(top, text="Trigger Mode").grid(row = 15, column = 0)
    popupMenu1.config(width=7)
    popupMenu1.grid(row = 16, column=0, sticky='nsew')
    popupMenu1_tip = CreateToolTip(popupMenu1, "Trigger Mode (a)")

    Display_var_list = ['YT', 'XY', 'YX']
    Display_var = StringVar()
    Display_var.set('YT')
    popupMenu0 = OptionMenu(top, Display_var, *Display_var_list)
    Label(top, text="Display Mode").grid(row = 17, column = 0)
    popupMenu0.config(width=7)
    popupMenu0.grid(row = 18, column=0, sticky='nsew')
    popupMenu0_tip = CreateToolTip(popupMenu0, "Select trace display type (H:up, h:down)")

    Math_var_list = ['CH1-CH2', 'CH2-CH1', 'CH1+CH2']
    Math_var = StringVar()
    Math_var.set('CH1-CH2')
    popupMenuA = OptionMenu(top, Math_var, *Math_var_list)
    Label(top, text="Math").grid(row = 15, column = 5)
    popupMenuA.config(width=7)
    popupMenuA.grid(row = 16, column=5, sticky='nsew')
    popupMenuA_tip = CreateToolTip(popupMenuA, "Selects math trace operation (F:up, f:down)")

    Channel_var_list = ['CH1', 'CH2']
    Channel_var = StringVar()
    Channel_var.set('CH1')
    popupMenu2 = OptionMenu(top, Channel_var, *Channel_var_list)
    Label(top, text="Trigger Source").grid(row = 15, column = 1)
    popupMenu2.config(width=7)
    popupMenu2.grid(row = 16, column=1, sticky='nsew')
    popupMenu2_tip = CreateToolTip(popupMenu2, "Trigger Source (b)")

    Edge_var_list = ['Rising', 'Falling']
    Edge_var = StringVar()
    Edge_var.set('Rising')
    popupMenu3 = OptionMenu(top, Edge_var, *Edge_var_list)
    Label(top, text="Trigger Edge").grid(row = 15, column = 2)
    popupMenu3.config(width=7)
    popupMenu3.grid(row = 16, column=2, sticky='nsew')
    popupMenu3_tip = CreateToolTip(popupMenu3, "Trigger Edge (c)")

    Rate_var_list = ['500', '250', '125', '62.5', '31.25', '15.63', '7.81', '3.9']
    Rate_var = StringVar()
    Rate_var.set('15.63')
    popupMenu4 = OptionMenu(top, Rate_var, *Rate_var_list)
    Label(top, text="Capture Rate (kHz)").grid(row = 15, column = 3)
    popupMenu4.config(width=7)
    popupMenu4.grid(row = 16, column=3, sticky='nsew')
    popupMenu4_tip = CreateToolTip(popupMenu4, "Capture Rate (D:up, d:down)")

    Click_var_list = ['V trigg', 'Cursor 1', 'Cursor 2', 'Zero CH1', 'Zero CH2', 'Nothing!']
    Click_var = StringVar()
    Click_var.set('Nothing!')
    popupMenu5 = OptionMenu(top, Click_var, *Click_var_list, command = ResetCnt_Callback)
    Label(top, text="Click on plot sets").grid(row = 15, column = 4)
    popupMenu5.config(width=7)
    popupMenu5.grid(row = 16, column=4, sticky='nsew')
    popupMenu5_tip = CreateToolTip(popupMenu5, "Click on plot sets (E:up, e:down)")

    Run_Stop_Var= StringVar()
    Run_Stop_Var.set('Stop')
    Run_Stop_Button=Button(top, textvariable=Run_Stop_Var, width=7, bg='red',  command = Run_Stop_Callback)
    Run_Stop_Button.grid(row=0, column=5, sticky='nsew')
    Run_Stop_Button_tip = CreateToolTip(Run_Stop_Button, "Freezes the plot graph ()")
   
    CH1_on = BooleanVar()

    ChkButton1=Checkbutton(top, text="CH1", variable=CH1_on, command = UpdateLabels)
    ChkButton1.grid(row=3, column=6, sticky=W)
    CH1_on.set(True)
    ChkButton1_tip = CreateToolTip(ChkButton1, "Show/hide CH1 trace ($)")

    CH2_on = BooleanVar()
    ChkButton2=Checkbutton(top, text="CH2", variable=CH2_on, command = UpdateLabels)
    ChkButton2.grid(row=4, column=6, sticky=W)
    CH2_on.set(True)
    ChkButton2_tip = CreateToolTip(ChkButton2, "Show/hide CH2 trace (%)")
    
    Cursor1_on = BooleanVar()
    ChkButton3=Checkbutton(top, text="Cursor 1", variable=Cursor1_on)
    ChkButton3.grid(row=5, column=6, sticky=W)
    Cursor1_on.set(True)
    ChkButton3_tip = CreateToolTip(ChkButton3, "Show/hide Cursor 1 traces (^)")
    
    Cursor2_on = BooleanVar()
    ChkButton4=Checkbutton(top, text="Cursor 2", variable=Cursor2_on)
    ChkButton4.grid(row=6, column=6, sticky=W)
    Cursor2_on.set(True)
    ChkButton4_tip = CreateToolTip(ChkButton4, "Show/hide Cursor 2 traces (&)")
    
    Freq_on = BooleanVar()
    ChkButton5=Checkbutton(top, text="Freq", variable=Freq_on)
    ChkButton5.grid(row=7, column=6, sticky=W)
    Freq_on.set(True)
    ChkButton5_tip = CreateToolTip(ChkButton5, "Show/hide frequency/max values (*)")
     
    Vtrig_on = BooleanVar()
    ChkButton6=Checkbutton(top, text="V Trigg", variable=Vtrig_on)
    ChkButton6.grid(row=8, column=6, sticky=W)
    Vtrig_on.set(True)
    ChkButton6_tip = CreateToolTip(ChkButton6, "Show/hide trigger voltage level '('")

    Math_on = BooleanVar()
    ChkButton7=Checkbutton(top, text="Math", variable=Math_on)
    ChkButton7.grid(row=9, column=6, sticky=W)
    Math_on.set(False)
    ChkButton7_tip = CreateToolTip(ChkButton7, "Show/hide math trace ')'")

    Button1=Button(top, width=12, text = "Exit",  command = Just_Exit)
    Button1.grid(row=19, column=5, sticky='nsew')
    top.protocol('WM_DELETE_WINDOW', Just_Exit)
    Button1_tip = CreateToolTip(Button1, "Exits the program. (x or X)")

    CH1G = 0.0
    CH1G_var_list = ['8', '4', '2', '1', '0.5', '0.2', '0.1', '0.05']
    CH1G_var = StringVar()
    CH1G_var.set('4')
    popupMenu6 = OptionMenu(top, CH1G_var, *CH1G_var_list)
    Label(top, text="CH1 (V/Div)").grid(row = 17, column = 1)
    popupMenu6.config(width=7)
    popupMenu6.grid(row = 18, column=1, sticky='nsew')
    popupMenu6_tip = CreateToolTip(popupMenu6, "Channel 1 gain. (I:up, i:down)")

    CH1_Inv_on = BooleanVar()
    ChkButton8=Checkbutton(top, text="Invert CH1", variable=CH1_Inv_on)
    ChkButton8.grid(row=19, column=1)
    CH1_Inv_on.set(False)
    ChkButton8_tip = CreateToolTip(ChkButton8, "When selected trace is -CH1. (~)")

    CH2G = 0.0
    CH2G_var_list = ['8', '4', '2', '1', '0.5', '0.2', '0.1', '0.05']
    CH2G_var = StringVar()
    CH2G_var.set('4')
    popupMenu7 = OptionMenu(top, CH2G_var, *CH2G_var_list)
    Label(top, text="CH2 (V/Div)").grid(row = 17, column = 3)
    popupMenu7.config(width=7)
    popupMenu7.grid(row = 18, column=3, sticky='nsew')
    popupMenu7_tip = CreateToolTip(popupMenu7, "Channel 2 gain. (K:up, k:down)")

    CH2_Inv_on = BooleanVar()
    ChkButton9=Checkbutton(top, text="Invert CH2", variable=CH2_Inv_on)
    ChkButton9.grid(row=19, column=3)
    CH2_Inv_on.set(False)
    ChkButton9_tip = CreateToolTip(ChkButton9, "When selected trace is -CH2. (@)")

    CH1M = StringVar()
    CH1M.set('??')
    CH1M_var_list = ['AC', 'DC']
    CH1M_var = StringVar()
    CH1M_var.set('DC')
    popupMenu8 = OptionMenu(top, CH1M_var, *CH1M_var_list)
    Label(top, text="CH1 MODE").grid(row = 17, column = 2)
    popupMenu8.config(width=7)
    popupMenu8.grid(row = 18, column=2, sticky='nsew')
    popupMenu8_tip = CreateToolTip(popupMenu8, "Selects coupling for Channel 1. (J:up, j:down)")

    CH1_DSP_on = BooleanVar()
    ChkButtonA=Checkbutton(top, text="DSP CH1", variable=CH1_DSP_on)
    ChkButtonA.grid(row=19, column=2)
    CH1_DSP_on.set(False)
    ChkButtonA_tip = CreateToolTip(ChkButtonA, "Low pass filter for CH1. (!)")

    CH2M = StringVar()
    CH2M.set('??')
    CH2M_var_list = ['AC', 'DC']
    CH2M_var = StringVar()
    CH2M_var.set('DC')
    popupMenu9 = OptionMenu(top, CH2M_var, *CH2M_var_list)
    Label(top, text="CH2 MODE").grid(row = 17, column = 4)
    popupMenu9.config(width=7)
    popupMenu9.grid(row = 18, column=4, sticky='nsew')
    popupMenu9_tip = CreateToolTip(popupMenu9, "Selects coupling for Channel 2. (L:up, l:down)")

    CH2_DSP_on = BooleanVar()
    ChkButtonB=Checkbutton(top, text="DSP CH2", variable=CH2_DSP_on)
    ChkButtonB.grid(row=19, column=4)
    CH2_DSP_on.set(False)
    ChkButtonB_tip = CreateToolTip(ChkButtonB, "Low pass filter for CH2. (#)")

    # Quick access to Generator commands, assuming the generator is connected!
    Gen_Cmmd_var_list = ['Out1 Amplitude', 'Out2 Amplitude', 'Out1 Offset', 'Out2 Offset', 'Frequency', 'Phase', \
                        'Out1 Sine', 'Out2 Sine', 'Out1 Square', 'Out2 Square', 'Out1 Triangle', 'Out2 Triangle', 'Out1 Ramp', 'Out2 Ramp', \
                        'Save', 'Restore', 'On', 'Off', 'None']
    Gen_Cmmd_var = StringVar()
    Gen_Cmmd_var.set('Out1 Amplitude')
    popupMenu10 = OptionMenu(top, Gen_Cmmd_var, *Gen_Cmmd_var_list)
    Label(top, text="Generator Command").grid(row = 15, column = 6)
    popupMenu10.config(width=12)
    popupMenu10.grid(row = 16, column=6)
    popupMenu10_tip = CreateToolTip(popupMenu10, "Selects a generator command. (G:up, g:down)")

    Entry1 = Entry(top, width=15)
    Entry1.config(width=12)
    Entry1.grid(row = 17, column=6)
    Entry1.insert(0, '10')
    Entry1.bind('<Return>', on_enter)
    Entry1_tip = CreateToolTip(Entry1, "Parameter for generator commands.")

    Gen_Cmd=Button(top, width=15, text = "Set Generator",  command = GeneratorCommand)
    Gen_Cmd.grid(row=18, column=6)
    Gen_Cmd_tip = CreateToolTip(Gen_Cmd, "Applies the generator command. (z)")

    # Make the cells with the plot on it resizeble.  That way the plot expands/compress when the size of the main window changes.
    top.grid_columnconfigure(0,weight=1)
    top.grid_columnconfigure(1,weight=1)
    top.grid_columnconfigure(2,weight=1)
    top.grid_columnconfigure(3,weight=1)
    top.grid_columnconfigure(4,weight=1)
    top.grid_columnconfigure(5,weight=1)
    top.grid_rowconfigure(1,weight=1)
    top.grid_rowconfigure(2,weight=1)
    top.grid_rowconfigure(3,weight=1)
    top.grid_rowconfigure(4,weight=1)
    top.grid_rowconfigure(5,weight=1)
    top.grid_rowconfigure(6,weight=1)
    top.grid_rowconfigure(7,weight=1)
    top.grid_rowconfigure(8,weight=1)

    # Nothing visible until we receive information from BB2Scope
    CH1_zero.set_visible(0)
    CH2_zero.set_visible(0)
    line_ch1.set_visible(0)
    line_ch2.set_visible(0)
    line_trigger.set_visible(0)
    line_cursor1_x.set_visible(0)
    line_cursor1_y.set_visible(0)
    line_cursor2_x.set_visible(0)
    line_cursor2_y.set_visible(0)
    screen_msg.set_visible(0)
    line_Math.set_visible(0)    
    line_XY.set_visible(0)    
              
    top.update()

# ------------------------------------------------------------------------------------------------------------
def Init_Globals():
    global sampling_frequency, Num_Samples, Top_X, Ref_Voltage
    global CH1_prev_zero_val, CH2_prev_zero_val
    global Prev_Display_var
    global LastClickCnt
    global FirstRun, moving_average_factor
    global Label_type

    sampling_frequency=1
    Num_Samples = int((64 * 16)/2)
    Top_X = Num_Samples - 1
    Ref_Voltage = 3.35
    CH1_zero_val=0
    CH2_zero_val=0
    CH1_prev_zero_val=-10
    CH2_prev_zero_val=-10
    Prev_Display_var='no_YT'
    LastClickCnt=50
    FirstRun=1
    moving_average_factor=0.1 # The smaller it is, the smoother and slower it gets.  In a few seconds, smooth waveforms are displayed.
    Label_type=0


# ------------------------------------------------------------------------------------------------------------
# WARNING: in Linux (Debian) you must be a member of group 'dialout' to access serial ports:
# $ sudo gpasswd --add ${USER} dialout
def Init_Serial_Port():
    global ser, Label4_val, Label5_val
    
    try:
        ser.close()
    except:
        dummy=0

    portlist=list(serial.tools.list_ports.comports())
    #portlist=[["COM35",0]]
    for item in portlist:
        if ('USB Serial Port' in item.description) or ('FT230X' in item.description):
            Label5_val.set("Trying " + item.description)
            #print("Trying: " + item.description)
            top.update()
            try:
                ser = serial.Serial(port=item[0], baudrate=115200, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_TWO, bytesize=serial.EIGHTBITS, timeout=0.5)
                ser.write(b'.....\n')
                time.sleep(0.1)
                ser.write(b'I') # ID command.  Response from the microcontroller should be 'S'
                instr = ser.read(1)
                pstring = instr.decode()
                if len(pstring) == 1:
                    if pstring[0]=='S':
                        break
                    else:
                        ser.close()
                else:
                    ser.close()
            except:
                Label5_val.set(item[0] + " Not accesible")
                #print(item[0] + " Not accesible")

    try:
        #print("Connected to " + item[0])
        Label5_val.set("")
        Label4_val.set(item[0])
        ser.isOpen()
        ser.reset_output_buffer()
        ser.reset_input_buffer()
    except:
        Label4_val.set("")

#------------------------------------------------------------------------------------------   
def butter_lowpass_filter(data, fs, order):
    cutoff=fs/10
    nyquistf=fs/2.0
    normal_cutoff = cutoff / nyquistf
    # Get the filter coefficients 
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    y = filtfilt(b, a, data)
    return y

#------------------------------------------------------------------------------------------   
def Refresh_Plot():
    global sampling_frequency, Num_Samples
    global Run_Stop_Var
    global ch1, ch2
    global average_ch1, average_ch2, moving_average_factor, dynamic_factor
    global CH1_on, CH2_on, Cursor1_on, Cursor2_on, Freq_on, Vtrig_on
    global Math_on, Math_var
    global CH1G_var, CH2G_var
    global CH1G, CH2G
    global CH1M_var, CH2M_var, CH1M, CH2M
    global CH1_zero_val, CH2_zero_val
    global CH1_prev_zero_val, CH2_prev_zero_val
    global CH1_Inv_on, CH2_Inv_on, CH1_DSP_on, CH2_DSP_on
    global LastClickCnt
    global Prev_Display_var, Click_var
    global FirstRun
    global Label_type

    if LastClickCnt<50:
        LastClickCnt=LastClickCnt+1
        if LastClickCnt==50:
            Click_var.set('Nothing!')

    try:
        ser.reset_input_buffer()

        if Display_var.get()=='YT':
            CH1_zero.set_visible(1)
            CH2_zero.set_visible(1)
            line_ch1.set_visible(CH1_on.get())
            line_ch2.set_visible(CH2_on.get())
            line_trigger.set_visible(Vtrig_on.get())
            line_cursor1_x.set_visible(Cursor1_on.get())
            line_cursor1_y.set_visible(Cursor1_on.get())
            line_cursor2_x.set_visible(Cursor2_on.get())
            line_cursor2_y.set_visible(Cursor2_on.get())
            screen_msg.set_visible(Freq_on.get())
            line_Math.set_visible(Math_on.get())    
            line_XY.set_visible(0)    
        else: # This is for 'XY' or 'YX' parametric plots
            CH1_zero.set_visible(0)
            CH2_zero.set_visible(0)
            line_ch1.set_visible(0)
            line_ch2.set_visible(0)
            line_trigger.set_visible(0)
            line_cursor1_x.set_visible(0)
            line_cursor1_y.set_visible(0)
            line_cursor2_x.set_visible(0)
            line_cursor2_y.set_visible(0)
            screen_msg.set_visible(0)
            line_Math.set_visible(0)    
            line_XY.set_visible(1)    

        if Display_var.get()=='YT' and Prev_Display_var!='YT':
            Prev_Display_var='YT'
            ax.set_xlabel('t (ms)', fontsize=10)
            ax.set_xlim(0, Top_X/sampling_frequency)
            ax.set_xticks(np.arange(0, Top_X/sampling_frequency, 50/sampling_frequency))
            UpdateLabels()
        elif Display_var.get()!='YT' and  Prev_Display_var=='YT':
            Prev_Display_var='notYT'
            ax.set_xlabel('Div', fontsize=10)
            xlimit=4
            ax.set_xlim(-xlimit, xlimit)
            ax.set_xticks(np.arange(-xlimit, xlimit, 1))
            ax.set_ylabel('Div', fontsize=10)

        Str_Mode=CH1M_var.get()
        if(CH1M!=Str_Mode):
            CH1M=Str_Mode
            if Str_Mode=='AC':
                ser.write('M1A'.encode('UTF8'))
            elif Str_Mode=='DC':
                ser.write('M1D'.encode('UTF8'))
            UpdateLabels()
            dynamic_factor=1.0

        Str_Mode=CH2M_var.get()
        if(CH2M!=Str_Mode):
            CH2M=Str_Mode
            if Str_Mode=='AC':
                ser.write('M2A'.encode('UTF8'))
            elif Str_Mode=='DC':
                ser.write('M2D'.encode('UTF8'))
            UpdateLabels()
            dynamic_factor=1.0

        Str_Gain=CH1G_var.get()
        if(CH1G!=float(Str_Gain)):
            CH1G=float(Str_Gain)
            if Str_Gain=='8':
                ser.write('G10'.encode('UTF8'))
            elif Str_Gain=='4':
                ser.write('G11'.encode('UTF8'))
            elif Str_Gain=='2':
                ser.write('G12'.encode('UTF8'))
            elif Str_Gain=='1':
                ser.write('G13'.encode('UTF8'))
            elif Str_Gain=='0.5':
                ser.write('G14'.encode('UTF8'))
            elif Str_Gain=='0.2':
                ser.write('G15'.encode('UTF8'))
            elif Str_Gain=='0.1':
                ser.write('G16'.encode('UTF8'))
            elif Str_Gain=='0.05':
                ser.write('G17'.encode('UTF8'))
            time.sleep(0.01) # The 'G' command causes some significant math in the microcontroller that takes time, so wait 10ms before sending next command.
            UpdateLabels()
            dynamic_factor=1.0

        Str_Gain=CH2G_var.get()
        if(CH2G!=float(Str_Gain)):
            CH2G=float(Str_Gain)
            if Str_Gain=='8':
                ser.write('G20'.encode('UTF8'))
            elif Str_Gain=='4':
                ser.write('G21'.encode('UTF8'))
            elif Str_Gain=='2':
                ser.write('G22'.encode('UTF8'))
            elif Str_Gain=='1':
                ser.write('G23'.encode('UTF8'))
            elif Str_Gain=='0.5':
                ser.write('G24'.encode('UTF8'))
            elif Str_Gain=='0.2':
                ser.write('G25'.encode('UTF8'))
            elif Str_Gain=='0.1':
                ser.write('G26'.encode('UTF8'))
            elif Str_Gain=='0.05':
                ser.write('G27'.encode('UTF8'))
            time.sleep(0.01) # The 'G' command causes some significant math in the microcontroller that takes time, so wait 10ms before sending next command.
            UpdateLabels()
            dynamic_factor=1.0

        if Run_Stop_Var.get()=='Run':
            canvas.draw()
            top.after(100, Refresh_Plot)
            return
        
        Str_Rate=Rate_var.get()
        if(sampling_frequency!=float(Str_Rate)):
            sampling_frequency=float(Str_Rate)
            if Str_Rate=='500':
                ser.write('R0'.encode('UTF8'))
                ser.timeout=0.2   
            elif Str_Rate=='250':
                ser.write('R1'.encode('UTF8'))
                ser.timeout=0.2*2
            elif Str_Rate=='125':
                ser.write('R2'.encode('UTF8'))
                ser.timeout=0.2*4
            elif Str_Rate=='62.5':
                ser.write('R3'.encode('UTF8'))
                ser.timeout=0.2*8
            elif Str_Rate=='31.25':
                ser.write('R4'.encode('UTF8'))
                ser.timeout=0.2*16
            elif Str_Rate=='15.63':
                ser.write('R5'.encode('UTF8'))
                ser.timeout=0.2*32
            elif Str_Rate=='7.81':
                ser.write('R6'.encode('UTF8'))
                ser.timeout=0.2*64
            elif Str_Rate=='3.9':
                ser.write('R7'.encode('UTF8'))
                ser.timeout=0.2*128
            UpdateLabels()
            dynamic_factor=1.0

            if Display_var.get()=='YT':
                ax.set_xlim(0, Top_X/sampling_frequency)
                ax.set_xticks(np.arange(0, Top_X/sampling_frequency, 50/sampling_frequency))
            screen_msg.set_position([(50/sampling_frequency), 4.5])
            x = np.arange(0, Num_Samples, 1)
            x = x / sampling_frequency
            line_ch1.set_xdata(x)
            line_ch2.set_xdata(x)
            line_Math.set_xdata(x)
            
            line_trigger.set_data([0, Top_X/sampling_frequency], [V_Trigger, V_Trigger])           
      
        str1=Mode_var.get()
        str2=Channel_var.get()
        str3=Edge_var.get()

        if CH1_prev_zero_val!=CH1_zero_val:
            CH1_prev_zero_val=CH1_zero_val
            s="O1%04d" % (int(CH1_zero_val*(2048/4.125)+2047.0)) # 4*(1.65/1.6)=4.125
            #print(s)
            ser.write(s.encode('UTF8'))
            if CH2_prev_zero_val!=CH2_zero_val:
                time.sleep(0.01) # The 'O' command causes some significant math in the microcontroller that takes time...
            Label5_val.set("")
        if CH2_prev_zero_val!=CH2_zero_val:
            CH2_prev_zero_val=CH2_zero_val
            s="O2%04d" % (int(CH2_zero_val*(2048/4.125)+2047.0)) # 4*(1.65/1.6)=4.125
            #print(s)
            ser.write(s.encode('UTF8'))
            Label5_val.set("")

        s="%c%c%c%c" % (str1[0], str2[2], str3[0], int((V_Trigger+4)*(0x3f/8))) # for the trigger voltage, the range in the screen is -4 to +4

        if str1 != 'Auto Average':
            dynamic_factor=1.0 # In auto/normal modes no moving average.  Moving average only in mode 'Auto Average'.
          
        ser.write(s.encode('UTF8')) # Sends something like this: 'N1R\x15'.encode('UTF8') which means 'Capture Normal, Trigg CH1, Rissing Edge, Trigg volt is 15
        strin = ser.read(int(Num_Samples*2)+2) # Two channels, one byte per sample, plus two bytes for CRC16 at the end

        if(len(strin)==(int(Num_Samples*2)+2)):
            if CH1_Inv_on.get():
                k1=-1.0*(4.0/1.6) # (4.0/1.6) is the scale-up factor to screen dimensions
            else:
                k1=1.0*(4.0/1.6)

            if CH2_Inv_on.get():
                k2=-1.0*(4.0/1.6)
            else:
                k2=1.0*(4.0/1.6)

            # For some reason if this is not done at least once, the moving average doesn't work.
            # This is pending a proper solution.
            if FirstRun==1:
                ch1=butter_lowpass_filter(ch1, sampling_frequency, 2)           
                ch2=butter_lowpass_filter(ch2, sampling_frequency, 2)
                FirstRun=0

            for x in range(0, int(Num_Samples*2), 2): # 'strin' has the captured data for CH1 and CH2.  CH1 is in even locations, CH2 is in odd locations
                ch1[int(x/2)]=k1*((int(strin[int(x)])*Ref_Voltage/255.0)-(Ref_Voltage/2.0))
                ch2[int(x/2)]=k2*((int(strin[int(x)+1])*Ref_Voltage/255.0)-(Ref_Voltage/2.0))

                if abs(average_ch1[int(x/2)]-ch1[int(x/2)]) > 0.3:
                    dynamic_factor=1.0 # Signal has changed too much, signal to restart the moving average
                if abs(average_ch2[int(x/2)]-ch2[int(x/2)]) > 0.3:
                    dynamic_factor=1.0 # Signal has changed too much, signal to restart the moving average              

            ch1_max=-1000.0
            ch2_max=-1000.0
            ch1_min=1000.0
            ch2_min=1000.0
            ch1_ave=0.0
            ch2_ave=0.0
            ch1_rms=0.0
            ch2_rms=0.0
            
            for j in range(0, Num_Samples, 1):
                # Calculate the moving average. (No moving average if dynamic_factor=1.0. dynamic_factor=1.0 is also done to re-start the moving average after a change)              
                average_ch1[j]=ch1[j]=ch1[j]*dynamic_factor+average_ch1[j]*(1.0-dynamic_factor)              
                average_ch2[j]=ch2[j]=ch2[j]*dynamic_factor+average_ch2[j]*(1.0-dynamic_factor)

                # Check for the maximun for each channel
                if ch1[j]>ch1_max:
                   ch1_max=ch1[j]
                if ch2[j]>ch2_max:
                   ch2_max=ch2[j]
            
                # Check for the minimum for each channel
                if ch1[j]<ch1_min:
                   ch1_min=ch1[j]
                if ch2[j]<ch2_min:
                   ch2_min=ch2[j]

                # Accumulate average
                ch1_ave=ch1_ave+ch1[j]
                ch2_ave=ch2_ave+ch2[j]

                # Accumulate RMS
                ch1_rms=ch1_rms+ch1[j]*ch1[j]
                ch2_rms=ch2_rms+ch2[j]*ch2[j]

            # Finalize average calculation
            ch1_ave=ch1_ave/Num_Samples
            ch2_ave=ch2_ave/Num_Samples

            # Finalize rms calculation
            ch1_rms=math.sqrt(ch1_rms/Num_Samples)
            ch2_rms=math.sqrt(ch2_rms/Num_Samples)
            
            dynamic_factor=moving_average_factor

            # If enabled, apply DSP to the signals just acquired.  A second order Butterworth low pass filter seems to work well.
            if CH1_DSP_on.get():
                ch1=butter_lowpass_filter(ch1, sampling_frequency, 2)           
            if CH2_DSP_on.get():
                ch2=butter_lowpass_filter(ch2, sampling_frequency, 2)

            # Maybe use the methods listed here https://gist.github.com/endolith/255291 to find the frequency?
            # This is actually one of the methods described in the link above.  Seems to work quite well when a full period is captured.
            freq=0;
            if str2[2]=='1': # When trigger is from channel 1
                for x in range(6, int(Num_Samples)-5, 1):
                    if str3[0]=='R':
                        if (ch1[0]>=ch1[int(x)]) and (ch1[0]<=ch1[int(x)+5]): # Hysteresis
                            freq=(float(Str_Rate)*1e3/(x+5))
                            break
                    else:
                        if (ch1[0]<=ch1[int(x)]) and (ch1[0]>=ch1[int(x)+5]):
                            freq=(float(Str_Rate)*1e3/(x+5))
                            break

            if str2[2]=='2': # When trigger is from channel 2
                for x in range(6, int(Num_Samples)-5, 1):
                    if str3[0]=='R':
                        if (ch2[0]>=ch2[int(x)]) and (ch2[0]<=ch2[int(x)+5]):
                            freq=(float(Str_Rate)*1e3/(x+5))
                            break
                    else:
                        if (ch2[0]<=ch2[int(x)]) and (ch2[0]>=ch2[int(x)+5]):
                            freq=(float(Str_Rate)*1e3/(x+5))
                            break

            crc=crc16_ccitt(0, strin) # Validate the received data by checking that the CRC16 is correct
            
            if (crc!=0):
                screen_msg.set_text("No Trigger") # In normal mode, if no trigger data is received with incorrect CRC16.  It is better this way than timming out.
            else:
                if (freq!=0):
                    s="freq=%.2fHz" % (freq)
                else:
                    s="freq=???"
                if CH1_on.get() and CH2_on.get():
                    if Label_type==0:
                        screen_msg.set_text("%s, CH1 max=%.2fV, CH2 max=%.2fV" % (s, ch1_max*CH1G, ch2_max*CH2G))
                    elif Label_type==1:
                        screen_msg.set_text("%s, CH1 min=%.2fV, CH2 min=%.2fV" % (s, ch1_min*CH1G, ch2_min*CH2G))
                    elif Label_type==2:
                        screen_msg.set_text("%s, CH1 Vpp=%.2fV, CH2 Vpp=%.2fV" % (s, (ch1_max-ch1_min)*CH1G, (ch2_max-ch2_min)*CH2G))
                    elif Label_type==3:
                        screen_msg.set_text("%s, CH1 Ave=%.2fV, CH2 Ave=%.2fV" % (s, ch1_ave*CH1G, ch2_ave*CH2G))
                    elif Label_type==4:
                        screen_msg.set_text("%s, CH1 RMS=%.2fV, CH2 RMS=%.2fV" % (s, ch1_rms*CH1G, ch2_rms*CH2G))
                elif CH1_on.get():
                    if Label_type==0:
                        screen_msg.set_text("%s, CH1 max=%.2fV" % (s, ch1_max*CH1G))
                    elif Label_type==1:
                        screen_msg.set_text("%s, CH1 min=%.2fV" % (s, ch1_min*CH1G))
                    elif Label_type==2:
                        screen_msg.set_text("%s, CH1 Vpp=%.2fV" % (s, (ch1_max-ch1_min)*CH1G))
                    elif Label_type==3:
                        screen_msg.set_text("%s, CH1 Ave=%.2fV" % (s, ch1_ave*CH1G))
                    elif Label_type==4:
                        screen_msg.set_text("%s, CH1 RMS=%.2fV" % (s, ch1_rms*CH1G))
                elif CH2_on.get():
                    if Label_type==0:
                        screen_msg.set_text("%s, CH2 max=%.2fV" % (s, ch2_max*CH2G))
                    elif Label_type==1:
                        screen_msg.set_text("%s, CH2 min=%.2fV" % (s, ch2_min*CH2G))
                    elif Label_type==2:
                        screen_msg.set_text("%s, CH2 Vpp=%.2fV" % (s, (ch2_max-ch2_min)*CH2G))
                    elif Label_type==3:
                        screen_msg.set_text("%s, CH2 Ave=%.2fV" % (s, ch2_ave*CH2G))
                    elif Label_type==4:
                        screen_msg.set_text("%s, CH2 RMS=%.2fV" % (s, ch2_rms*CH2G))
                else:
                    screen_msg.set_text("")
 
                # Update the channel traces
                line_ch1.set_ydata(ch1)
                line_ch2.set_ydata(ch2)

                # Update the math trace    
                if Math_var.get()=='CH1-CH2':
                    line_Math.set_ydata(ch1-ch2)
                elif Math_var.get()=='CH2-CH1':
                    line_Math.set_ydata(ch2-ch1)
                elif Math_var.get()=='CH1+CH2':
                    line_Math.set_ydata(ch1+ch2)

                # Update the parametric trace
                if Display_var.get()=='XY':
                    line_XY.set_data(ch1, ch2)
                elif Display_var.get()=='YX':
                    line_XY.set_data(ch2, ch1)
                
            canvas.draw()
            Label5_val.set("")
        else:
            Label5_val.set("Wrong data size in Refresh_Plot()")
        top.after(100, Refresh_Plot)
    except:
        Label5_val.set("Exception in Refresh_Plot(). Will attempt to reconnect.")
        #print("Exception in Refresh_Plot(). Will attempt to reconnect.")
        CH1M="?"
        CH2M="?"
        CH1G=0
        CH2G=0
        sampling_frequency=1
        CH1_prev_zero_val=1000
        CH2_prev_zero_val=1000
        dynamic_factor=1.0
        Init_Serial_Port()
        top.after(500, Refresh_Plot)
   
#------------------------------------------------------------------------------------------   
def main():
    Init_Globals()
    Init_GUI()
    Init_Serial_Port()
    top.after(100, Refresh_Plot)
    top.mainloop()

#------------------------------------------------------------------------------------------   
if __name__ == "__main__":
    main()        
