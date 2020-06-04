# nextcloud_UUID_to_AD_mapping
small repo with script to map all NextCloud UUID's to ActiveDirectory

search_objectguid_nc.ps1 = script file
search_objectguid_nc.txt = plain file, where each line holds a NextCloud UUID (this is a demo file on the Git Repo)

When running the script, it generates a plain output.txt file (in fact, a csv file) with each line holding ObjectGUID;samAccountname;Displayname
