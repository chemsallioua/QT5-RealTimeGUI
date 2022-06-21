# This Python file uses the following encoding: utf-8
import MainGui
import sys

if __name__ == "__main__":

    main_window = MainGui.gui(
                          HOST='127.0.0.1',
                          PORT=7000,
                          ChartBoundaryMaxY=1000,
                          ChartBoundaryMinY=-1000,
                          MaxSpeed=None,
                          MinSpeed=None,
                          MaxTTC=None,
                          MinTTC=None)

    ret = main_window.run()
    sys.exit(ret)
