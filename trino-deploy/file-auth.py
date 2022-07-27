import subprocess
from subprocess import call
import json


user_token_dict = {}
current_db_users=[]

# Create a token/api key for each user
def generate_user_token(user):
    token=subprocess.getoutput("openssl rand -base64 12")
    #print (token)
    user_token_dict[user]=token

# Add/Update the password.db file for new profiles
def append_to_password_db(username, password):
    #print(password)
    call ('htpasswd -b -B -C 10 password.db ' + username + ' ' + password, shell=True)



def main():
    with open('password.db', "r+") as t:
        for line in  t:
            user= line.split(":", 1)
            current_db_users.append(user[0])
            # print(user[0])

    aaw_profiles=[]
    # All Profiles in AAW
    with open('profiles.txt',"r") as f:
        for line in f:
            profile=line.replace('"', "").strip()
            aaw_profiles.append(profile)
            #print (line)

    for u in aaw_profiles:
        if (u not in current_db_users): # Create new entries in password file for newly created Profiles
            print ("User " + u + " does not exist in password.db")
            generate_user_token(u)
            append_to_password_db(u, user_token_dict[u])
            print (user_token_dict[u])
            # Create secrets in each namespace
            call("kubectl create secret generic trino-auth --from-literal=password="+ user_token_dict[u] + " -n " + u, shell=True)
            print ("Created secret trino-auth in namespace: " + u )

    # Export Dictionary to file. Do not commit!
    with open('pw_dict.txt', 'w') as convert_file:
        convert_file.write(json.dumps(user_token_dict))


if __name__ == "__main__":
    main()