

const snapAttestationSchema = (attestorAddress, creatorAddress) => {
    return {
        //  schemaId; // The unique identifier of the schema.
        // schemaNumber; // The schema number.
        creator: creatorAddress, // The address of the schema creator.
        attestor: attestorAddress, // The address of the Attestor smart contract.
        isPrivate: false, // Whether the schema is private or public.
        onChainAttestation: true, // Whether the schema requires on-chain attestation.
        schema: '0x00' // The schema string.
    }
}

module.exports = {
    schemas: {
        snapAttestationSchema
    }
}