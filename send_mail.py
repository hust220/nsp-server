#! /usr/bin/python 

import os, smtplib, mimetypes, sys, re
from email.mime.text import MIMEText 
from email.mime.image import MIMEImage 
from email.mime.multipart import MIMEMultipart 

class SendMail:
    def __init__(self, user = 'wj_hust08', postfix = 'hust.edu.cn', password = '31j0n8i0a1', to = ['wj_hust08@hust.edu.cn'], host = 'mail.hust.edu.cn'):
        self._host = host
        self._user = user
        self._postfix = postfix
        self._pass = password
        self._to = to
        self._from = self._user + '<' + self._user + '@' + self._postfix + '>'

    def __call__(self, subject, content, filename = None): 
        try: 
            message = MIMEMultipart() 
            message.attach(MIMEText(content)) 
            message["Subject"] = subject 
            message["From"] = self._from 
            message["To"] = ";".join(self._to) 
            if filename != None and os.path.exists(filename): 
                ctype, encoding = mimetypes.guess_type(filename) 
                if ctype is None or encoding is not None: 
                    ctype = "application/octet-stream"
                maintype, subtype = ctype.split("/", 1) 
                attachment = MIMEImage((lambda f: (f.read(), f.close()))(open(filename, "rb"))[0], _subtype = subtype) 
                attachment.add_header("Content-Disposition", "attachment", filename = os.path.basename(filename)) 
                message.attach(attachment) 
        
            smtp = smtplib.SMTP() 
            smtp.connect(self._host) 
            smtp.login(self._user, self._pass) 
            smtp.sendmail(self._from, self._to, message.as_string()) 
            smtp.quit() 
            return True
        except Exception, errmsg: 
            print "Send mail failed to: %s" % errmsg 
            return False
     
if __name__ == "__main__": 
    par = {}
    key = ''
    for i in sys.argv[1:]:
        if i[0] == '-':
            key = i[1:]
            par[key] = []
        else:
            par[key].append(i)
    send_mail = SendMail(to = par['to'])
    content = ''
    if 'file' in par.keys():
        if len(par['file']) == 0:
            flag = 1
            try:
                line = raw_input()
            except:
                line = ''
                flag = 0
            while flag:
                content += line + '\n'
                try:
                    line = raw_input()
                except:
                    break
        else:
            content = open(par['file'][0]).read()
    else:
        content = par['content'][0]
    if 'attach' in par.keys():
        send_mail(par['subject'][0], content, par['attach'][0])
    else:
        send_mail(par['subject'][0], content)

