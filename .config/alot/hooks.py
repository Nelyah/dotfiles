import alot
import re


def pre_buffer_focus(ui, dbm, buf):
	if buf.modename == 'search':
		buf.rebuild()


async def pre_envelope_send(ui, dbm, cmd):
    e = ui.current_buffer.envelope
    regex_attach = r'[Aa]ttach|[Pp]i[eè]ces?[\ -]?[Jj]ointes?|([Cc]i[\ -]?joint)'
    
    if re.match(regex_attach, e.body, re.DOTALL) and not e.attachments:
        msg = 'no attachments. send anyway?'
        if not (await ui.choice(msg, select='yes')) == 'yes':
            raise Exception()


def pre_buffer_open(ui, dbm, buf):
    current = ui.current_buffer
    if isinstance(current, alot.buffers.SearchBuffer):
        current.focused_thread = current.get_selected_thread()   # remember focus


def post_buffer_focus(ui, dbm, buf, success):
    if success and hasattr(buf, "focused_thread"):  # if buffer has saved focus
        if buf.focused_thread is not None:
            tid = buf.focused_thread.get_thread_id() 
            for pos, tlw in enumerate(buf.threadlist.get_lines()):
                if tlw.get_thread().get_thread_id() == tid:
                    buf.body.set_focus(pos)
                    break
