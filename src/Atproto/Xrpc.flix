mod Atproto.Xrpc {

    use Atproto.XrpcError
    use Atproto.XrpcError.XrpcError.{Transport, Protocol, Decode}
    use Net.HttpRequest
    use Util.Json.FromJson
    use Util.Json.FromJson.{decodeAtKeyOpt}

    def parseErrorBody(body: String): (String, String) =
        match Util.Json.parse(body) {
            case Err(_) => ("", "")
            case Ok(j)  =>
                let errStr = match decodeAtKeyOpt("error", j) {
                    case Ok(Some(s)) => s
                    case _           => ""
                };
                let msgStr = match decodeAtKeyOpt("message", j) {
                    case Ok(Some(s)) => s
                    case _           => ""
                };
                (errStr, msgStr)
        }

    def sendRequest(req: HttpRequest): Result[XrpcError, a] \ Net.Http.Http with FromJson[a] =
        match Net.Http.send(req) {
            case Err(ioErr) => Err(Transport(ioErr))
            case Ok(resp)   =>
                if (Net.HttpResponse.isSuccess(resp)) {
                    match Util.Json.decode(Net.HttpResponse.body(resp)) {
                        case Ok(v)  => Ok(v)
                        case Err(e) => Err(Decode(e))
                    }
                } else {
                    let st = Net.HttpResponse.status(resp);
                    let (errStr, msgStr) = parseErrorBody(Net.HttpResponse.body(resp));
                    Err(Protocol({ status = st, error = errStr, message = msgStr }))
                }
        }

    pub def xrpcQuery(nsid: String, params: List[(String, String)]): Result[XrpcError, a] \ Net.Http.Http with FromJson[a] =
        let baseReq = Net.HttpRequest.get("/xrpc/${nsid}");
        let req = List.foldLeft(
            (r, kv) -> match kv {
                case (k, v) => Net.HttpRequest.withQueryParam(k, v, r)
            },
            baseReq,
            params
        );
        sendRequest(req)

}
