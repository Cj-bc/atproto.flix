mod Test.Actor {

    use Atproto.XrpcError
    use Bsky.Actor.ProfileViewDetailed
    use Bsky.Actor.ProfileViewDetailed.ProfileViewDetailed
    use Net.Body
    use Net.HttpResponse
    use Net.HttpResponse.HttpResponse
    use Util.Json.JsonError
    use Util.Json.JsonError.DecodeErrorKind.{MissingKey}

    def mockResp(status: Int32, body: String): HttpResponse =
        HttpResponse({
            url     = "",
            status  = status,
            headers = Map.empty(),
            body    = Body.Body.Text(body)
        })

    def runWithMock(json: String): Result[XrpcError, ProfileViewDetailed] =
        run {
            Bsky.Actor.getProfile("test.bsky.social")
        } with handler Net.Http.Http {
            def request(_, k) = k(Ok(mockResp(200, json)))
        }

    // Test 1a: success with all optional fields
    @Test
    def testDecodeFullProfile(): Unit \ Assert =
        let json = String.concat(
            String.concat("{\"did\":\"did:plc:abc\",\"handle\":\"test.bsky.social\",",
                          "\"displayName\":\"Test User\",\"description\":\"A bio\","),
            String.concat("\"website\":\"https://example.com\",\"banner\":\"https://cdn/banner.jpg\",",
                          "\"followersCount\":42,\"followsCount\":10,\"postsCount\":100,\"createdAt\":\"2023-01-01T00:00:00Z\"}")
        );
        match runWithMock(json) {
            case Ok(p) =>
                Assert.assertEq(expected = "did:plc:abc",      ProfileViewDetailed.did(p));
                Assert.assertEq(expected = "test.bsky.social", ProfileViewDetailed.handle(p));
                Assert.assertEq(expected = Some("Test User"),  ProfileViewDetailed.displayName(p));
                Assert.assertEq(expected = Some("A bio"),      ProfileViewDetailed.description(p));
                Assert.assertEq(expected = Some("https://example.com"), ProfileViewDetailed.website(p));
                Assert.assertEq(expected = Some("https://cdn/banner.jpg"), ProfileViewDetailed.banner(p));
                Assert.assertEq(expected = Some(42i64),        ProfileViewDetailed.followersCount(p));
                Assert.assertEq(expected = Some(10i64),        ProfileViewDetailed.followsCount(p));
                Assert.assertEq(expected = Some(100i64),       ProfileViewDetailed.postsCount(p));
                Assert.assertEq(expected = Some("2023-01-01T00:00:00Z"), ProfileViewDetailed.createdAt(p))
            case Err(e) => Assert.fail("Expected Ok, got ${e}")
        }

    // Test 1b: success with only required fields
    @Test
    def testDecodeMinimalProfile(): Unit \ Assert =
        let json = "{\"did\":\"did:plc:min\",\"handle\":\"min.bsky.social\"}";
        match runWithMock(json) {
            case Ok(p) =>
                Assert.assertEq(expected = "did:plc:min",       ProfileViewDetailed.did(p));
                Assert.assertEq(expected = "min.bsky.social",   ProfileViewDetailed.handle(p));
                Assert.assertEq(expected = None,                ProfileViewDetailed.displayName(p));
                Assert.assertEq(expected = None,                ProfileViewDetailed.followersCount(p))
            case Err(e) => Assert.fail("Expected Ok, got ${e}")
        }

    // Test 2: unknown fields are ignored
    @Test
    def testUnknownFieldsIgnored(): Unit \ Assert =
        let json = String.concat(
            "{\"did\":\"did:plc:x\",\"handle\":\"x.bsky.social\",",
            "\"futureField\":{\"nested\":true},\"anotherNew\":123}"
        );
        match runWithMock(json) {
            case Ok(p) =>
                Assert.assertEq(expected = "did:plc:x", ProfileViewDetailed.did(p))
            case Err(e) => Assert.fail("Expected Ok with unknown fields ignored, got ${e}")
        }

    // Test 5: missing required 'did' -> Decode error with MissingKey("did")
    @Test
    def testMissingDidField(): Unit \ Assert =
        let json = "{\"handle\":\"no-did.bsky.social\"}";
        match runWithMock(json) {
            case Err(XrpcError.Decode(je)) =>
                match je {
                    case JsonError.Decode(_, MissingKey(k)) =>
                        Assert.assertEq(expected = "did", k)
                    case _ => Assert.fail("Expected MissingKey error")
                }
            case Ok(_)  => Assert.fail("Expected Decode error")
            case Err(e) => Assert.fail("Expected Decode error, got ${e}")
        }

}
