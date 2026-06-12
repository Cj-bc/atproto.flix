def main(): Unit \ IO =
    run {
        Net.Http.withBaseUrl("https://public.api.bsky.app", () ->
            match Bsky.Actor.getProfile("bsky.app") {
                case Ok(p) =>
                    println("=== Profile ===");
                    println("DID:         ${Bsky.Actor.did(p)}");
                    println("Handle:      @${Bsky.Actor.handle(p)}");
                    println("DisplayName: ${Option.getWithDefault("(none)", Bsky.Actor.displayName(p))}");
                    println("Description: ${Option.getWithDefault("(none)", Bsky.Actor.description(p))}");
                    println("Followers:   ${Option.map(Int64.toString, Bsky.Actor.followersCount(p)) |> Option.getWithDefault("(none)")}");
                    println("Following:   ${Option.map(Int64.toString, Bsky.Actor.followsCount(p)) |> Option.getWithDefault("(none)")}");
                    println("Posts:       ${Option.map(Int64.toString, Bsky.Actor.postsCount(p)) |> Option.getWithDefault("(none)")}")
                case Err(e) =>
                    println("Error: ${e}")
            }
        )
    } with Net.Http.runWithIO
