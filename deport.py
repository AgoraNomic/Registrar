import subprocess
from datetime import datetime, timezone

# Update the relevant mboxes
ao_update = "wget -c https://agora:nomic@mailman.agoranomic.org/archives/agora-official.mbox"
ab_update = "wget -c https://agora:nomic@mailman.agoranomic.org/archives/agora-business.mbox"

print(subprocess.run(ao_update.split(), capture_output=True, text=True).stdout)
print(subprocess.run(ab_update.split(), capture_output=True, text=True).stdout)

# TODO: Replace this list with a call to the spreadsheet or json file(s) with all the players
emails = ["notorious4st@gmail.com", "callforjudgement@yahoo.co.uk", "createsource.nomic@gmail.com", "rose.strong42@gmail.com", "hdrussell@outlook.com", "skullcat.test@gmail.com", "kerim@uw.edu", "gbs@canishe.com", "jason.e.cobb@gmail.com", "juan@juanmeleiro.mat.br", "madridnomic@gmail.com", "murphy.agora@gmail.com", "nixagora@proton.me", "comexk@gmail.com", "sarahestrange0@gmail.com", "secretsnail9@gmail.com", "agoratelna@iprimus.com.au", "reuben.staley@gmail.com"]

td = datetime.now(timezone.utc)

def postAge(post):
   postd = {}
   postd["mon"] = datetime.strptime(post[1], '%b').month
   postd["yr"] = post[4]
   postd["day"] = post[2]
   postd["hr"], postd["min"], postd["sec"] = post[3].split(":")
   
   post_date = datetime(int(postd["yr"]),int(postd["mon"]),int(postd["day"]),int(postd["hr"]),int(postd["min"]),int(postd["sec"]), tzinfo=timezone.utc)
   
   return((td-post_date).days)

# TODO: When a player is already inactive, check if it's been x days since
# TODO: When a player is already inactive, check if e's posted since being deactivated
for email in emails:
    ao_command = "grep From.*" + email + ".*[0-9][0-9][0-9][0-9].* agora-official.mbox"
    ab_command = "grep From.*" + email + ".*[0-9][0-9][0-9][0-9].* agora-business.mbox"
    #last_ao = subprocess.run(ao_command.split(), capture_output=True, text=True).stdout.split("\n")[-2].split()[2:]
    try:
        last_ao = subprocess.run(ao_command.split(), capture_output=True, text=True).stdout.split("\n")[-2].split()[2:]
        last_post = postAge(last_ao)
    except:
        #print("no ao: " + email)
        last_post = 1000
    try:
        last_ab = subprocess.run(ab_command.split(), capture_output=True, text=True).stdout.split("\n")[-2].split()[2:]
        last_post = min(last_post, postAge(last_ab))
    except:
        last_post = min(last_post, 1000)
    
    if last_post > 30:
        print(email + ": " + str(last_post) + " days ago")
