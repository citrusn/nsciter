include xapi, event , valueprocs

when defined(posix):
    # {.passC: "-std=c++11".}
    {.passC: gorge("pkg-config gtk+-3.0 --cflags").}
    {.passL: gorge("pkg-config gtk+-3.0 --libs").}
    const
        gtkhdr = "<gtk/gtk.h>"
        gtklib = "libgtk-3.so.0"
    type
        GtkWidget {.final, header: gtkhdr, importc.} = object
        GtkWindow {.final, header: gtkhdr, importc.} = object
    {.emit:
        """
        #include <gtk/gtk.h>
        GtkWindow* gwindow(GtkWidget* hwnd) {
            printf("hwnd:%d\n", hwnd);
            return GTK_WINDOW(gtk_widget_get_toplevel(hwnd));
        }
        """
    .}
    proc gwindow(h: ptr GtkWidget): ptr GtkWindow {.importc: "gwindow".}
    proc gtk_init(a, b: int) {.dynlib: gtklib, importc: "gtk_init".}
    proc gtk_main() {.dynlib: gtklib, importc: "gtk_main".}
    proc gtk_window_present(w: ptr GtkWindow) {.
        dynlib: gtklib, importc: "gtk_window_present".}
    proc gtk_window_set_title(w: ptr GtkWindow, title: cstring) {.
        dynlib: gtklib, importc: "gtk_window_set_title".}
    proc gtk_widget_get_toplevel(w: ptr GtkWidget): ptr GtkWidget {.
        dynlib: gtklib, importc: "gtk_widget_get_toplevel".}
    gtk_init(0, 0)
    proc setTitle*(h: HWINDOW, title: string) =
        # setTitle set the window title for the GTK window
        var w = gwindow(cast[ptr GtkWidget](h))
        gtk_window_set_title(w, cstring(title))
    proc run*(hwnd: HWINDOW) =
        # run start the underly GTK window for sciter
        var w = gtk_widget_get_toplevel(cast[ptr GtkWidget](hwnd))
        gtk_window_present(gwindow(w))
        gtk_main()

when defined(windows):
    proc SetWindowText(wnd: HWINDOW, lpString: WideCString): bool {.
        stdcall, dynlib: "user32", importc: "SetWindowTextW".}
    proc GetMessage(lpMsg: ptr MSG, wnd: HWINDOW, wMsgFilterMin: uint32,
                    wMsgFilterMax: uint32): bool {.
        stdcall, dynlib: "user32", importc: "GetMessageW".}
    proc TranslateMessage(lpMsg: ptr MSG): bool {.
        stdcall, dynlib: "user32", importc: "TranslateMessage".}
    proc DispatchMessage(lpMsg: ptr MSG): LONG{.
        stdcall, dynlib: "user32", importc: "DispatchMessageW".}
    proc UpdateWindow(wnd: HWINDOW): bool{.
        stdcall, dynlib: "user32", importc: "UpdateWindow".}
    proc OleInitialize*(pvReserved: pointer): HRESULT {.
        stdcall, discardable, dynlib: "ole32", importc: "OleInitialize".}
    proc OleUninitialize*(): HRESULT {.
        stdcall, discardable, dynlib: "ole32", importc: "OleUninitialize".}

    proc ShowWindow(wnd: HWINDOW, nCmdShow: int32): WINBOOL{.
        stdcall, dynlib: "user32", importc: "ShowWindow".}
    proc setTitle*(h: HWINDOW, title: string) =
        discard SetWindowText(h, newWideCString(title))

    proc run*(hwnd: HWINDOW) =
        var m: MSG
        discard hwnd.ShowWindow(5)
        discard hwnd.UpdateWindow()
        while GetMessage(m.addr, nil, 0, 0):
            discard TranslateMessage(m.addr)
            discard DispatchMessage(m.addr)

proc VersionAsString*(): string = 
    var major = SciterVersion(true)
    var minor = SciterVersion(false)    
    return fmt"{major shr 16}.{major and 0xffff}.{minor shr 16}.{minor and 0xffff}"       

#proc defaultRect*(): ref Rect = #result = cast[ref Rect](alloc0(sizeof(Rect)))
let defaultRect*: RectRef = RectRef(left: 10, top: 50, right: 600, bottom: 400)

## # Open data blob of the provided compressed Sciter archive.
proc OpenArchive*(data: openarray[byte]): HSARCHIVE =
    var l: uint32 = data.len.uint32
    var d: ptr byte = data[0].unsafeAddr
    return SciterOpenArchive(d, l)

## # Get an archive item referenced by \c uri.
#
## # Usually it is passed to \c Sciter.DataReady().
proc GetArchiveItem*(harc: HSARCHIVE, uri: string): (ptr UncheckedArray[byte], int32) =
    var data: ptr UncheckedArray[byte]
    var length: uint32
    echo "GetArchiveItem uri: ", uri
    var r = SciterGetArchiveItem(harc, uri, cast[ptr pointer](data.addr), length)
    #result = newSeq[byte](length)
    #result=data
    if not r:
        return (data, 0'i32)
    #ret := ByteCPtrToBytes(data, length)
    #echo data.len, data
    return (data, length.int32)

## # Close the archive
proc CloseArchive*(harc: var HSARCHIVE): bool =   
    result = SciterCloseArchive(harc)
    harc = nil       

#[Register `this://app/` URLs to be loaded from the given Sciter archive.
  Pack resources using `packfolder` tool:
   `$ packfolder res_folder res_packed.go -v resource_name -go`
  Usage:
    win.SetResourceArchive(resource_name)
    win.LoadFile("this://app//index.htm")
]#
proc SetResourceArchive*(data: openarray[byte]): HSARCHIVE =
    var harc = OpenArchive(data)
    doassert not harc.isNil
    return harc

## #This function is used in response to SCN_LOAD_DATA request.
##
##  \param[in] hwnd \b HWINDOW, Sciter window handle.
##  \param[in] uri \b LPCWSTR, URI of the data requested by Sciter.
##  \param[in] data \b LPBYTE, pointer to data buffer.
##  \param[in] dataLength \b UINT, length of the data in bytes.
##  \return \b BOOL, TRUE if Sciter accepts the data or \c FALSE if error occured
##  (for example this function was called outside of #SCN_LOAD_DATA request).
##
##  \warning If used, call of this function MUST be done ONLY while handling
##  SCN_LOAD_DATA request and in the same thread. For asynchronous resource loading
##  use SciterDataReadyAsync
proc DataReady*(wnd:HWINDOW, uri: string, data:openarray[byte]): bool =         
    var ret = wnd.SciterDataReady(uri, cast[pointer](data), cast[uint32](data.len) )
    #if not ret :
    #   return false    
    ## mark the data to prevent gc
    #loadedUri[uri] = data
    return ret
