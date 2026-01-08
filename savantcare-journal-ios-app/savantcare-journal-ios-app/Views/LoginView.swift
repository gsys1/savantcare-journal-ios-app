import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Binding var isLoggedIn: Bool
    
    enum LoginMethod {
        case email, otp
    }
    @State private var loginMethod: LoginMethod = .otp
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo/Header
                VStack(spacing: 10) {
                    Image(systemName: "heart.text.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("SavantCare Journal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Let your doctor know how you are doing between appointments.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Login Form
                VStack(spacing: 15) {
                    Picker("Login Method", selection: $loginMethod) {
                        Text("OTP").tag(LoginMethod.otp)
                        Text("Password").tag(LoginMethod.email)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    if loginMethod == .email {
                        emailLoginForm
                    } else {
                        otpLoginForm
                    }
                }
                .padding(.horizontal, 10)
                
                Spacer()
                
                // Footer
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
    
    var emailLoginForm: some View {
        VStack(spacing: 15) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
                .padding(.horizontal)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                Task {
                    await viewModel.login()
                    if viewModel.isAuthenticated {
                        isLoggedIn = true
                    }
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Login")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
            .padding(.horizontal)
        }
    }
    
    var otpLoginForm: some View {
        VStack(spacing: 15) {
            TextField("Enter Phone or Email", text: $viewModel.otpSource)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.default)
                .textContentType(.username)
                .autocapitalization(.none)
                .padding(.horizontal)
                .disabled(viewModel.isOtpSent)
            
            if viewModel.isOtpSent {
                TextField("OTP", text: $viewModel.otpCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .padding(.horizontal)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                Task {
                    if viewModel.isOtpSent {
                        await viewModel.verifyOTP()
                        if viewModel.isAuthenticated {
                            isLoggedIn = true
                        }
                    } else {
                        await viewModel.sendOTP()
                    }
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(viewModel.isOtpSent ? "Verify & Login" : "Request OTP")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(viewModel.isLoading || viewModel.otpSource.isEmpty || (viewModel.isOtpSent && viewModel.otpCode.isEmpty))
            .padding(.horizontal)
            
            if viewModel.isOtpSent {
                Button("Use different number") {
                    viewModel.isOtpSent = false
                    viewModel.otpCode = ""
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
    }
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    @Published var otpSource = ""
    @Published var otpCode = ""
    @Published var isOtpSent = false
    
    init() {}
    
    func login() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await AuthService.shared.login(email: email, password: password)
            isAuthenticated = true
            isLoading = false
            print("✅ Login successful for user: \(user.emailAddress)")
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
    }
    
    func sendOTP() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let success = try await AuthService.shared.sendOTP(otpSource: otpSource)
            if success {
                isOtpSent = true
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func verifyOTP() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await AuthService.shared.verifyOTP(otpSource: otpSource, otp: otpCode)
            isAuthenticated = true
            isLoading = false
            print("✅ OTP Login successful for user: \(user.emailAddress)")
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
    }
}