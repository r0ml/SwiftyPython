
import SwiftUI
import Caerbannog

extension Demo {
  static public func runBotoDemo() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.center()
    window.setFrameAutosaveName("Boto Demo")
    window.isReleasedWhenClosed = false
    window.contentView = NSHostingView(rootView: BotoView())
    window.makeKeyAndOrderFront(nil)
  }
}

struct BotoView : View {
  @State var accessKey : String = ""
  @State var secretKey : String = ""
  @State var result : String = "no result yet"
  
  var body : some View {
    VStack() {
      TextField("Access Key", text: $accessKey)
      TextField("Secret Key", text: $secretKey)
      Text("This demo will generate a list of your S3 buckets.  You need to provide your AWS access and secret key").lineLimit(3).multilineTextAlignment(.leading).padding().fixedSize(horizontal: false, vertical: true)
      Button("Run Boto S3") { self.result = self.runBotoDemo().joined(separator: "\n") }
      ScrollView(.vertical, showsIndicators: true) {
        Text(result).fixedSize(horizontal: true, vertical: true ).frame(alignment: .leading).padding()
      }.frame(maxWidth:.infinity, alignment: .leading).background(Color(NSColor.darkGray)).padding()
    }
  }
  
  func runBotoDemo() -> [String] {
    let str = """
import boto3

    ## Or via the Session
    #session = boto3.Session(
    #    aws_access_key_id=ACCESS_KEY,
    #    aws_secret_access_key=SECRET_KEY,
    #    aws_session_token=SESSION_TOKEN,
    #)

    # Retrieve the list of existing buckets
s3 = boto3.client('s3', aws_access_key_id=ACCESS_KEY, aws_secret_access_key=SECRET_KEY)
response = s3.list_buckets()

    # Output the bucket names
result = []

for bucket in response['Buckets']:
    result.append(bucket["Name"])

"""
    
    // Sets the global variables (in __main__)
    Python.ACCESS_KEY = self.accessKey
    Python.SECRET_KEY = self.secretKey
    
    // Evaluates the program in str and returns the named global variable(s)
    if let zz = Python.run(str, returning: "result") {
      return [String](zz)!
    } else {
      return ["boto request failed"]
    }
    
  }
}

struct Boto_Previews: PreviewProvider {
  static var previews: some View {
    BotoView()
  }
}
