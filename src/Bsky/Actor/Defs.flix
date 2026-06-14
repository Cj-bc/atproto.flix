/// Types declared in the `app.bsky.actor.defs` lexicon.
///
/// Scalar fields are decoded into typed fields. Structured sub-objects
/// (`associated`, `viewer`, `labels`, `verification`, `status`, `pinnedPost`,
/// `joinedViaStarterPack`) and `unknown` fields (`debug`) reference further
/// lexicon types; they are preserved as raw `Json` rather than fully modelled.

mod Bsky.Actor.ProfileViewDetailed {

    use Util.Json.Json
    use Util.Json.JsonError
    use Util.Json.FromJson.{decodeAtKey, decodeAtKeyOpt}

    /// `app.bsky.actor.defs#profileViewDetailed`.
    pub enum ProfileViewDetailed({
        did                  = String,
        handle               = String,
        displayName          = Option[String],
        description          = Option[String],
        pronouns             = Option[String],
        website              = Option[String],
        avatar               = Option[String],
        banner               = Option[String],
        followersCount       = Option[Int64],
        followsCount         = Option[Int64],
        postsCount           = Option[Int64],
        indexedAt            = Option[String],
        createdAt            = Option[String],
        associated           = Option[Json],
        joinedViaStarterPack = Option[Json],
        viewer               = Option[Json],
        labels               = Option[Json],
        pinnedPost           = Option[Json],
        verification         = Option[Json],
        status               = Option[Json],
        debug                = Option[Json]
    })

    pub def did(p: ProfileViewDetailed): String =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#did }

    pub def handle(p: ProfileViewDetailed): String =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#handle }

    pub def displayName(p: ProfileViewDetailed): Option[String] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#displayName }

    pub def description(p: ProfileViewDetailed): Option[String] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#description }

    pub def pronouns(p: ProfileViewDetailed): Option[String] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#pronouns }

    pub def website(p: ProfileViewDetailed): Option[String] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#website }

    pub def avatar(p: ProfileViewDetailed): Option[String] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#avatar }

    pub def banner(p: ProfileViewDetailed): Option[String] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#banner }

    pub def followersCount(p: ProfileViewDetailed): Option[Int64] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#followersCount }

    pub def followsCount(p: ProfileViewDetailed): Option[Int64] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#followsCount }

    pub def postsCount(p: ProfileViewDetailed): Option[Int64] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#postsCount }

    pub def indexedAt(p: ProfileViewDetailed): Option[String] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#indexedAt }

    pub def createdAt(p: ProfileViewDetailed): Option[String] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#createdAt }

    pub def associated(p: ProfileViewDetailed): Option[Json] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#associated }

    pub def joinedViaStarterPack(p: ProfileViewDetailed): Option[Json] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#joinedViaStarterPack }

    pub def viewer(p: ProfileViewDetailed): Option[Json] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#viewer }

    pub def labels(p: ProfileViewDetailed): Option[Json] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#labels }

    pub def pinnedPost(p: ProfileViewDetailed): Option[Json] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#pinnedPost }

    pub def verification(p: ProfileViewDetailed): Option[Json] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#verification }

    pub def status(p: ProfileViewDetailed): Option[Json] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#status }

    pub def debug(p: ProfileViewDetailed): Option[Json] =
        match p { case ProfileViewDetailed.ProfileViewDetailed(r) => r#debug }

    // Decoding is split into small groups so that no single `forM` chain grows
    // deep enough to overflow the Flix type-checker's constraint generator.
    type alias PvdIdentity = (String, String, Option[String], Option[String], Option[String], Option[String], Option[String])
    type alias PvdCounts   = (Option[String], Option[Int64], Option[Int64], Option[Int64], Option[String], Option[String], Option[Json])
    type alias PvdRefs     = (Option[Json], Option[Json], Option[Json], Option[Json], Option[Json], Option[Json], Option[Json])

    def decodeIdentity(j: Json): Result[JsonError, PvdIdentity] =
        forM (
            did         <- decodeAtKey("did", j);
            handle      <- decodeAtKey("handle", j);
            displayName <- decodeAtKeyOpt("displayName", j);
            description <- decodeAtKeyOpt("description", j);
            pronouns    <- decodeAtKeyOpt("pronouns", j);
            website     <- decodeAtKeyOpt("website", j);
            avatar      <- decodeAtKeyOpt("avatar", j)
        ) yield (did, handle, displayName, description, pronouns, website, avatar)

    def decodeCounts(j: Json): Result[JsonError, PvdCounts] =
        forM (
            banner         <- decodeAtKeyOpt("banner", j);
            followersCount <- decodeAtKeyOpt("followersCount", j);
            followsCount   <- decodeAtKeyOpt("followsCount", j);
            postsCount     <- decodeAtKeyOpt("postsCount", j);
            indexedAt      <- decodeAtKeyOpt("indexedAt", j);
            createdAt      <- decodeAtKeyOpt("createdAt", j);
            associated     <- decodeAtKeyOpt("associated", j)
        ) yield (banner, followersCount, followsCount, postsCount, indexedAt, createdAt, associated)

    def decodeRefs(j: Json): Result[JsonError, PvdRefs] =
        forM (
            joinedViaStarterPack <- decodeAtKeyOpt("joinedViaStarterPack", j);
            viewer               <- decodeAtKeyOpt("viewer", j);
            labels               <- decodeAtKeyOpt("labels", j);
            pinnedPost           <- decodeAtKeyOpt("pinnedPost", j);
            verification         <- decodeAtKeyOpt("verification", j);
            status               <- decodeAtKeyOpt("status", j);
            debug                <- decodeAtKeyOpt("debug", j)
        ) yield (joinedViaStarterPack, viewer, labels, pinnedPost, verification, status, debug)

    instance Util.Json.FromJson[ProfileViewDetailed] {
        pub def fromJson(j: Json): Result[JsonError, ProfileViewDetailed] =
            forM (
                i <- decodeIdentity(j);
                c <- decodeCounts(j);
                r <- decodeRefs(j)
            ) yield
                let (did, handle, displayName, description, pronouns, website, avatar) = i;
                let (banner, followersCount, followsCount, postsCount, indexedAt, createdAt, associated) = c;
                let (joinedViaStarterPack, viewer, labels, pinnedPost, verification, status, debug) = r;
                ProfileViewDetailed.ProfileViewDetailed({
                    did                  = did,
                    handle               = handle,
                    displayName          = displayName,
                    description          = description,
                    pronouns             = pronouns,
                    website              = website,
                    avatar               = avatar,
                    banner               = banner,
                    followersCount       = followersCount,
                    followsCount         = followsCount,
                    postsCount           = postsCount,
                    indexedAt            = indexedAt,
                    createdAt            = createdAt,
                    associated           = associated,
                    joinedViaStarterPack = joinedViaStarterPack,
                    viewer               = viewer,
                    labels               = labels,
                    pinnedPost           = pinnedPost,
                    verification         = verification,
                    status               = status,
                    debug                = debug
                })
    }

}
