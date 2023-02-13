def set_verbose(b):
    global g_useVerbose
    g_useVerbose = b

def verbose_print(s):
    if g_useVerbose:
        print(s)