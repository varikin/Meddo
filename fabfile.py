from fabric.api import env, local, hide, lcd 
from datetime import datetime
import os

env.zip = "build/Release/Meddo.zip"
env.app = "build/Release/Meddo.app"
env.private_key = "~/Dropbox/Developer/dsa_priv.pem"
env.helper = "/Library/PrivilegedHelperTools/com.fictitiousnonsense.MeddoHelper"
env.helper_plist = "/Library/LaunchDaemons/com.fictitiousnonsense.MeddoHelper.plist"

def clean():
    local("rm -f %s" % env.zip)
    with hide('stdout'):
        local("xcodebuild clean")


def build():
    clean()
    with hide('stdout'):
        local("xcodebuild -configuration Release")
    with lcd("build/Release"):
        local("zip --quiet -r Meddo.zip Meddo.app")
        signature = local("openssl dgst -sha1 -binary < Meddo.zip | openssl dgst -dss1 -sign %s | openssl enc -base64" % env.private_key, capture=True)
    print _app_cast_xml(signature)


    
def _app_cast_xml(signature):
    xml = """
<channel>
  <title>Changelog</title>
  <link>http://meddo.fictitiousnonsense.com/app/appcast.xml</link>
  <description>A release</description>
  <language>en</language>
     <item>
        <title>A release</title>
        <pubDate>%s</pubDate>
        <enclosure url="http://meddo.fictitiousnonsense.com/app/0.1/Meddo.zip" sparkle:version="0.1" length="%s" type="application/octet-stream" sparkle:dsaSignature="%s" />
     </item>
</channel>
    """
    now = datetime.now().strftime("%a, %d %b %Y, %H:%M -0600")
    size = os.path.getsize(env.zip)
    return xml % (now, size, signature)

def helper_clean():
    if os.path.exists(env.helper):
        local("sudo rm %s" %  env.helper)
    if os.path.exists(env.helper_plist):
        local("sudo rm %s" %  env.helper_plist)

def helper_status():
    if os.path.exists(env.helper):
        print "%s exists" % env.helper
    else:
        print "%s does not exist" % env.helper

    if os.path.exists(env.helper_plist):
        print "%s exists" % env.helper_plist
    else:
        print "%s does not exist" % env.helper_plist
