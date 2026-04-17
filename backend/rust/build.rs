// build.rs - Flutter Rust Bridge build script for NexaTrace Rust Module

use std::env;
use std::path::PathBuf;

fn main() {
    // Tell Cargo to rerun this build script if any of these files change
    println!("cargo:rerun-if-changed=src/lib.rs");
    println!("cargo:rerun-if-changed=src/models/mod.rs");
    println!("cargo:rerun-if-changed=src/generators/mod.rs");
    println!("cargo:rerun-if-changed=src/generators/bundle.rs");
    println!("cargo:rerun-if-changed=src/generators/carton.rs");
    println!("cargo:rerun-if-changed=src/generators/packet.rs");
    println!("cargo:rerun-if-changed=src/generators/unit.rs");
    println!("cargo:rerun-if-changed=src/generators/hierarchical.rs");
    println!("cargo:rerun-if-changed=src/algorithms/mod.rs");
    println!("cargo:rerun-if-changed=src/international/mod.rs");

    // Generate Flutter Rust Bridge code
    generate_flutter_rust_bridge();

    // Set up linking for different platforms
    setup_linking();
}

fn generate_flutter_rust_bridge() {
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    let bridge_file = out_dir.join("bridge_generated.rs");

    // Generate the bridge code
    flutter_rust_bridge_codegen::generate(
        flutter_rust_bridge_codegen::Opts {
            // Input Rust file
            rust_input: "src/lib.rs".to_string(),

            // Output directory for generated code
            dart_output: vec![
                "../lib/rust_module/bridge/nexatrace_rust_bridge.dart".to_string(),
            ],

            // Output Rust file
            rust_output: Some(bridge_file.to_str().unwrap().to_string()),

            // Additional options
            dart_format_line_length: 120,
            dart_decl_output: Some(
                "../lib/rust_module/bridge/nexatrace_rust_bridge.dart".to_string(),
            ),

            // Web support
            wasm: false,

            // FFI mode
            llvm_path: None,
            llvm_compiler_opts: None,

            // Skip modules
            skip_add_mod_to_lib: false,
            skip_deps_check: false,

            // Code generation options
            rust_bridge_generated_mod_path: Some("nexatrace_rust::bridge_generated".to_string()),

            // C bindings output (for FFI)
            c_output: Some(vec![
                "../lib/rust_module/bridge/bindings.h".to_string(),
                "../lib/rust_module/bridge/bindings.c".to_string(),
            ]),

            // Extra headers for C bindings
            extra_c_output_paths: None,

            // Swift/Kotlin bindings (for mobile)
            swift_bridge_support_path: None,
            kotlin_bridge_support_path: None,

            // Customize code generation
            dart_enums_style: false,
            dart_entrypoint_class_name: None,
            dart_root_namespace: None,

            // Logging
            verbose: false,
        },
    ).expect("Failed to generate Flutter Rust Bridge code");

    println!("cargo:warning=Flutter Rust Bridge code generated successfully");
    println!("cargo:warning=Dart output: ../lib/rust_module/bridge/nexatrace_rust_bridge.dart");
    println!("cargo:warning=C bindings: ../lib/rust_module/bridge/bindings.h");
}

fn setup_linking() {
    let target = env::var("TARGET").unwrap();

    // Platform-specific linking
    if target.contains("android") {
        setup_android_linking();
    } else if target.contains("ios") {
        setup_ios_linking();
    } else if target.contains("darwin") {
        setup_macos_linking();
    } else if target.contains("windows") {
        setup_windows_linking();
    } else if target.contains("linux") {
        setup_linux_linking();
    }
}

fn setup_android_linking() {
    println!("cargo:rustc-link-lib=log");
    println!("cargo:rustc-link-lib=android");

    // Android NDK setup
    if let Ok(ndk_home) = env::var("ANDROID_NDK_HOME") {
        let target = env::var("TARGET").unwrap();
        let arch = if target.contains("aarch64") {
            "arm64-v8a"
        } else if target.contains("armv7") {
            "armeabi-v7a"
        } else if target.contains("i686") {
            "x86"
        } else if target.contains("x86_64") {
            "x86_64"
        } else {
            panic!("Unsupported Android architecture: {}", target);
        };

        println!("cargo:warning=Android NDK found at: {}", ndk_home);
        println!("cargo:warning=Target architecture: {}", arch);
    }
}

fn setup_ios_linking() {
    println!("cargo:rustc-link-lib=framework=Foundation");
    println!("cargo:rustc-link-lib=framework=Security");

    // iOS frameworks
    let target = env::var("TARGET").unwrap();
    if target.contains("ios") {
        println!("cargo:rustc-link-lib=framework=UIKit");
        println!("cargo:rustc-link-lib=framework=CoreFoundation");
    }
}

fn setup_macos_linking() {
    println!("cargo:rustc-link-lib=framework=Foundation");
    println!("cargo:rustc-link-lib=framework=Security");
    println!("cargo:rustc-link-lib=framework=CoreFoundation");
}

fn setup_windows_linking() {
    println!("cargo:rustc-link-lib=advapi32");
    println!("cargo:rustc-link-lib=bcrypt");
    println!("cargo:rustc-link-lib=crypt32");
    println!("cargo:rustc-link-lib=user32");
}

fn setup_linux_linking() {
    println!("cargo:rustc-link-lib=dl");
    println!("cargo:rustc-link-lib=rt");
    println!("cargo:rustc-link-lib=pthread");
    println!("cargo:rustc-link-lib=gcc_s");
    println!("cargo:rustc-link-lib=c");
    println!("cargo:rustc-link-lib=m");
}

// Add build information
fn add_build_info() {
    let version = env::var("CARGO_PKG_VERSION").unwrap_or_else(|_| "0.1.0".to_string());
    let name = env::var("CARGO_PKG_NAME").unwrap_or_else(|_| "nexatrace_rust".to_string());

    println!("cargo:warning=Building {} v{}", name, version);
    println!("cargo:warning=Target: {}", env::var("TARGET").unwrap());
    println!("cargo:warning=Profile: {}", env::var("PROFILE").unwrap());
    println!("cargo:warning=Out dir: {}", env::var("OUT_DIR").unwrap());

    // Set build timestamp
    let timestamp = chrono::Utc::now().format("%Y-%m-%d %H:%M:%S UTC");
    println!("cargo:rustc-env=NEXATRACE_BUILD_TIMESTAMP={}", timestamp);
    println!("cargo:rustc-env=NEXATRACE_BUILD_VERSION={}", version);
}
