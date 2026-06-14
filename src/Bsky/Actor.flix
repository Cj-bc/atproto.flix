mod Bsky.Actor {

    use Atproto.XrpcError
    use Net.Http.Http
    use Bsky.Actor.ProfileViewDetailed.ProfileViewDetailed

    /// `app.bsky.actor.getProfile` — get a detailed profile view of an actor.
    /// Returns a `profileViewDetailed` (see `Bsky.Actor.ProfileViewDetailed`).
    /// Does not require auth, but returns additional metadata when authenticated.
    pub def getProfile(actor: String): Result[XrpcError, ProfileViewDetailed] \ Http =
        Atproto.Xrpc.xrpcQuery("app.bsky.actor.getProfile", ("actor", actor) :: Nil)

}
