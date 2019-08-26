

2019-08-06 09:22                       Can                        Page 1



NAME
     Can - F* library to manage content-addressable networks.

PROTOCOL
     These are the types of messages defined

     Heartbeat
	     It's a message periodically sent from a peer to all its
	     neighbors. Each heartbeat contains the list of the peer
	     that surrounds him.

     Join    It's a message sent from a node (A) that isn't part yet of
	     the network to a node (B) of the network. A pick a random
	     point in the space and send a Join to B with that point. We
	     have two options:

	     B owns the zone that contains the point wanted by A
		     In this case B can do two things:

		     o	 If one of the B neighbors owns a bigger zone,
			 forward the Join to him.

		     o	 or he can split its zone and telling the sender
			 of the fact. (Note that the sender may or may
			 not be A)

	     B does not own that zone
		     In this case B (without notice) forward the Join to
		     the nearest node.

     Split   Can only be sent as a reply to a Join.  The sender has
	     allocated half of its zone for the new node.




























