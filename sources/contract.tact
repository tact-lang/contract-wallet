import "@stdlib/deploy";

message TransferMessage {
    signature: Slice as bytes64;
    transfer: Slice as remaining;
}

contract Wallet {

    publicKey: Int as uint256;
    seqno: Int as uint64;
    walletId: Int as uint64;

    init(publicKey: Int, walletId: Int) {
        self.publicKey = publicKey;
        self.seqno = 0;
        self.walletId = walletId;
    }

    fun processTransfer(msg: TransferMessage, external: Bool)  {

        // Check Signature
        let op_hash: Int = msg.transfer.hash();
        require(checkSignature(op_hash, msg.signature, self.publicKey), "Invalid signature");

        // Check parameters
        let pkg: Slice = msg.transfer;
        let seqno: Int = pkg.loadInt(32);
        let mode: Int = pkg.loadInt(8);
        let body: Cell = pkg.loadRef();
        require(seqno == self.seqno, "Invalid seqno");

        // Accept message
        if (external) {
            acceptMessage();
        }

        // Increment seqno
        self.seqno = (self.seqno + 1);

        // Send message
        nativeSendMessage(body, mode);
    }

    receive(msg: TransferMessage) {
        self.processTransfer(msg, false);
    }

    external(msg: TransferMessage) {
        self.processTransfer(msg, true);
    }

    get fun seqno(): Int {
        return self.seqno;
    }
}