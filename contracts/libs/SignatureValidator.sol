pragma solidity 0.4.24;

library SignatureValidator {
	enum SignatureMode {
		EIP712,
		GETH,
		TREZOR
	}

	/// @dev Validates that a hash was signed by a specified signer.
	/// @param hash Hash which was signed.
	/// @param signer Address of the signer.
	/// @param signature ECDSA signature along with the mode (0 = EIP712, 1 = Geth, 2 = Trezor) {mode}{v}{r}{s}.
	/// @return Returns whether signature is from a specified user.
	function isValidSignature(bytes32 hash, address signer, byte[66] signature) internal pure returns (bool) {
		SignatureMode mode = SignatureMode(uint8(signature[0]));

		uint8 v = uint8(signature[1]);
		bytes32 r;
		bytes32 s;
		assembly {
			r := mload(add(signature, 34))
			s := mload(add(signature, 66))
		}

		if (mode == SignatureMode.GETH) {
			hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
		} else if (mode == SignatureMode.TREZOR) {
			hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n\x20", hash));
		}

		return ecrecover(hash, v, r, s) == signer;
	}
}