mod Bsky.Actor {

    use Atproto.XrpcError
    use Net.Http.Http
    use Util.Json.Json
    use Util.Json.JsonError
    use Util.Json.FromJson.{decodeAtKey, decodeAtKeyOpt}

    pub enum ProfileView({
        did            = String,
        handle         = String,
        displayName    = Option[String],
        description    = Option[String],
        avatar         = Option[String],
        followersCount = Option[Int64],
        followsCount   = Option[Int64],
        postsCount     = Option[Int64],
        createdAt      = Option[String]
    })

    pub def did(p: ProfileView): String = match p {
        case ProfileView.ProfileView(r) => r#did
    }

    pub def handle(p: ProfileView): String = match p {
        case ProfileView.ProfileView(r) => r#handle
    }

    pub def displayName(p: ProfileView): Option[String] = match p {
        case ProfileView.ProfileView(r) => r#displayName
    }

    pub def description(p: ProfileView): Option[String] = match p {
        case ProfileView.ProfileView(r) => r#description
    }

    pub def avatar(p: ProfileView): Option[String] = match p {
        case ProfileView.ProfileView(r) => r#avatar
    }

    pub def followersCount(p: ProfileView): Option[Int64] = match p {
        case ProfileView.ProfileView(r) => r#followersCount
    }

    pub def followsCount(p: ProfileView): Option[Int64] = match p {
        case ProfileView.ProfileView(r) => r#followsCount
    }

    pub def postsCount(p: ProfileView): Option[Int64] = match p {
        case ProfileView.ProfileView(r) => r#postsCount
    }

    pub def createdAt(p: ProfileView): Option[String] = match p {
        case ProfileView.ProfileView(r) => r#createdAt
    }

    instance Util.Json.FromJson[ProfileView] {
        pub def fromJson(j: Json): Result[JsonError, ProfileView] =
            forM (
                did            <- decodeAtKey("did", j);
                handle         <- decodeAtKey("handle", j);
                displayName    <- decodeAtKeyOpt("displayName", j);
                description    <- decodeAtKeyOpt("description", j);
                avatar         <- decodeAtKeyOpt("avatar", j);
                followersCount <- decodeAtKeyOpt("followersCount", j);
                followsCount   <- decodeAtKeyOpt("followsCount", j);
                postsCount     <- decodeAtKeyOpt("postsCount", j);
                createdAt      <- decodeAtKeyOpt("createdAt", j)
            ) yield ProfileView.ProfileView({
                did            = did,
                handle         = handle,
                displayName    = displayName,
                description    = description,
                avatar         = avatar,
                followersCount = followersCount,
                followsCount   = followsCount,
                postsCount     = postsCount,
                createdAt      = createdAt
            })
    }

    pub def getProfile(actor: String): Result[XrpcError, ProfileView] \ Http =
        Atproto.Xrpc.xrpcQuery("app.bsky.actor.getProfile", ("actor", actor) :: Nil)

}
