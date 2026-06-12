mod Atproto.XrpcError {

    use IoError.IoError
    use Util.Json.JsonError

    pub enum XrpcError {
        case Transport(IoError)
        case Protocol({ status = Int32, error = String, message = String })
        case Decode(JsonError)
    }

    instance ToString[XrpcError] {
        pub def toString(e: XrpcError): String = match e {
            case XrpcError.Transport(ioErr) =>
                "Transport error: ${ioErr}"
            case XrpcError.Protocol(r) =>
                "XRPC error ${r#status}: ${r#error} - ${r#message}"
            case XrpcError.Decode(jsonErr) =>
                "JSON decode error: ${jsonErr}"
        }
    }

}
