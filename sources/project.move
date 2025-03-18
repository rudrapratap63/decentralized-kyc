module MyModule::DecentralizedKYC {
    use std::error;
    use std::signer;
    use std::vector;
    use aptos_framework::account;
    
    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 0;
    const E_ALREADY_VERIFIED: u64 = 1;
    const E_NOT_VERIFIED: u64 = 2;
    
    /// Struct to store verification status for a user
    struct UserVerification has key {
        is_verified: bool,
        verification_data: vector<u8>, // Hash of KYC data
        verifier: address
    }
    
    /// Resource to track authorized verifiers
    struct VerifierRegistry has key {
        verifiers: vector<address>
    }
    
    /// Initialize the verifier registry (called by admin)
    public entry fun initialize_registry(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        
        // Ensure only the deployer can initialize
        assert!(admin_addr == @MyModule, error::permission_denied(E_NOT_AUTHORIZED));
        
        // Create and store the registry
        let verifiers = vector::empty<address>();
        vector::push_back(&mut verifiers, admin_addr); // Admin is the first verifier
        
        move_to(admin, VerifierRegistry { verifiers });
    }
    
    /// Add a new verifier (only admin can add verifiers)
    public entry fun add_verifier(admin: &signer, verifier_addr: address) acquires VerifierRegistry {
        let admin_addr = signer::address_of(admin);
        assert!(admin_addr == @MyModule, error::permission_denied(E_NOT_AUTHORIZED));
        
        let registry = borrow_global_mut<VerifierRegistry>(@MyModule);
        vector::push_back(&mut registry.verifiers, verifier_addr);
    }
    
    /// Function 1: Verify a user's identity (only callable by authorized verifiers)
    public entry fun verify_user(
        verifier: &signer, 
        user: &signer,
        verification_hash: vector<u8>
    ) acquires VerifierRegistry {
        let verifier_addr = signer::address_of(verifier);
        let user_addr = signer::address_of(user);
        
        // Check if verifier is authorized
        let registry = borrow_global<VerifierRegistry>(@MyModule);
        assert!(vector::contains(&registry.verifiers, &verifier_addr), error::permission_denied(E_NOT_AUTHORIZED));
        
        // Check if user is already verified
        assert!(!exists<UserVerification>(user_addr), error::already_exists(E_ALREADY_VERIFIED));
        
        // Create verification record
        let verification = UserVerification {
            is_verified: true,
            verification_data: verification_hash,
            verifier: verifier_addr
        };
        
        move_to(user, verification);
    }
    
    /// Function 2: Check verification status of a user
    public fun is_user_verified(user_addr: address): bool acquires UserVerification {
        if (!exists<UserVerification>(user_addr)) {
            return false
        };
        
        let verification = borrow_global<UserVerification>(user_addr);
        verification.is_verified
    }
    
    /// Allows a verifier to revoke a verification
    public entry fun revoke_verification(
        verifier: &signer,
        user_addr: address
    ) acquires VerifierRegistry, UserVerification {
        let verifier_addr = signer::address_of(verifier);
        
        // Check if verifier is authorized
        let registry = borrow_global<VerifierRegistry>(@MyModule);
        assert!(vector::contains(&registry.verifiers, &verifier_addr), error::permission_denied(E_NOT_AUTHORIZED));
        
        // Check if user is verified
        assert!(exists<UserVerification>(user_addr), error::not_found(E_NOT_VERIFIED));
        
        // Get and update verification status
        let verification = borrow_global_mut<UserVerification>(user_addr);
        verification.is_verified = false;
    }
}