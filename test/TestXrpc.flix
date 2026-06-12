mod Test.Xrpc {

    use Atproto.XrpcError
    use IoError.IoError
    use IoError.ErrorKind
    use Net.Body
    use Net.HttpResponse
    use Net.HttpResponse.HttpResponse
    use Util.Json.Json

    def mockResp(status: Int32, body: String): HttpResponse =
        HttpResponse({
            url     = "",
            status  = status,
            headers = Map.empty(),
            body    = Body.Body.Text(body)
        })

    // Test 3: XRPC Protocol error
    @Test
    def testProtocolError(): Unit \ Assert =
        let resp = mockResp(400, "{\"error\":\"InvalidRequest\",\"message\":\"bad actor\"}");
        let result: Result[XrpcError, Json] = run {
            Atproto.Xrpc.xrpcQuery("app.bsky.actor.getProfile", ("actor", "test") :: Nil)
        } with handler Net.Http.Http {
            def request(_, k) = k(Ok(resp))
        };
        match result {
            case Err(XrpcError.Protocol(r)) =>
                Assert.assertEq(expected = 400, r#status);
                Assert.assertEq(expected = "InvalidRequest", r#error);
                Assert.assertEq(expected = "bad actor", r#message)
            case _ => Assert.fail("Expected Protocol error")
        }

    // non-JSON error body -> Protocol with empty strings
    @Test
    def testProtocolNonJsonBody(): Unit \ Assert =
        let resp = mockResp(401, "not json");
        let result: Result[XrpcError, Json] = run {
            Atproto.Xrpc.xrpcQuery("app.bsky.actor.getProfile", ("actor", "test") :: Nil)
        } with handler Net.Http.Http {
            def request(_, k) = k(Ok(resp))
        };
        match result {
            case Err(XrpcError.Protocol(r)) =>
                Assert.assertEq(expected = 401, r#status);
                Assert.assertEq(expected = "", r#error);
                Assert.assertEq(expected = "", r#message)
            case _ => Assert.fail("Expected Protocol error")
        }

    // Test 4: transport error
    @Test
    def testTransportError(): Unit \ Assert =
        let ioErr = IoError.IoError(ErrorKind.ConnectionFailed, "mock");
        let result: Result[XrpcError, Json] = run {
            Atproto.Xrpc.xrpcQuery("app.bsky.actor.getProfile", ("actor", "test") :: Nil)
        } with handler Net.Http.Http {
            def request(_, k) = k(Err(ioErr))
        };
        match result {
            case Err(XrpcError.Transport(_)) => Assert.assertTrue(true)
            case _ => Assert.fail("Expected Transport error")
        }

    // Test 6: query parameter URL encoding
    @Test
    def testQueryEncoding(): Unit \ Assert =
        region rc {
            let capturedUrl: Ref[String, rc] = Ref.fresh(rc, "");
            let _ : Result[XrpcError, Json] = run {
                Atproto.Xrpc.xrpcQuery("test.nsid", ("key", "a b") :: ("k2", "x&y") :: Nil)
            } with handler Net.Http.Http {
                def request(req, k) = {
                    Ref.put(Net.HttpRequest.url(req), capturedUrl);
                    k(Ok(mockResp(200, "{}")))
                }
            };
            let url = Ref.get(capturedUrl);
            Assert.assertTrue(String.contains(substr = "key=a+b", url));
            Assert.assertTrue(String.contains(substr = "k2=x%26y", url))
        }

}
