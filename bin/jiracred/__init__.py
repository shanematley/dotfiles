from ConfigParser import SafeConfigParser
import keyring, os, getpass, urlparse, requests

CONFIG_DESC="""CONFIGURATION OF JIRA SCRIPTS

    A configuration file located at ~/.jira.config containing:

        [jira]
        server = https://jira
        username = myusername

"""

class Jira(object):
    def __init__(self, update_password=False):
        config = SafeConfigParser()
        config.read(os.path.expanduser('~/.jira.config'))
        self.jira_server = config.get('jira', 'server')
        self.username = config.get('jira', 'username')
        if not self.jira_server:
            raise Exception('Jira server required in ~/.jira.config')
        if not self.username:
            raise Exception('Jira username required in ~/.jira.config')
        self.password = keyring.get_password('jira_scripts', self.username)
        if not self.password or update_password:
            self.password = getpass.getpass('Password for {}:'.format(self.username))
            keyring.set_password('jira_scripts', self.username, self.password)

    def get(self, url):
        rest_uri = urlparse.urljoin(self.jira_server, '/rest/api/2/') + url
        r = requests.get(rest_uri, auth=(self.username, self.password), headers=({'Content-Type':'application/json'}), verify=False)
        r.raise_for_status()
        return r.json()

    def search(self, query):
        return self.get('search?jql=' + query)


