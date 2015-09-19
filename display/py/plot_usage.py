import time
import datetime
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.dates import DayLocator, MonthLocator, DateFormatter, date2num
import numpy as np

fpath = "../stats/master_log.txt"
cnt = np.loadtxt(fpath,usecols=(0,1,2,3,4,5,6,7,8,9))
rawdates = np.loadtxt(fpath,usecols=(10,),dtype=np.str)

#For some reason loadtxt puts garbage into the date strings
rawdates[:] = [x[2:-1] for x in rawdates]
#Convert string time stamp to datetime
dates = [time.strptime(x,"%Y_%m_%d") for x in rawdates]
dates[:] = [datetime.datetime.fromtimestamp(time.mktime(x)) for x in dates]
dates[:] = date2num(dates)

days = DayLocator()
months = MonthLocator()
monthFmt = DateFormatter('%b')

m = 0
colors = ['b','r','c','m','k','r','g','y','c','b']
fig, ax = plt.subplots(2,5)
for i in range(2):
    for j in range(5):
        ax[i,j].set_ylabel('Hits')
        ax[i,j].set_title('{}'.format(m+1))
        ax[i,j].plot_date(dates,cnt[:,m],'%s-' %colors[m])
        ax[i,j].xaxis.set_major_locator(months)
        ax[i,j].xaxis.set_major_formatter(monthFmt)
        ax[i,j].xaxis.set_minor_locator(days)
        ax[i,j].autoscale_view()
        ax[i,j].fmt_xdata = DateFormatter('%Y-%m-%d')
        ax[i,j].grid(True)
        fig.autofmt_xdate()
        m+=1

plt.tight_layout(pad=0.5,w_pad=-1,h_pad=-0.75)
fig.set_size_inches(20,11.25)
plt.savefig("../img/page_stats.png",orientation='landscape',frameon=1,bbox_inches='tight')
