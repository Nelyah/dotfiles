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
