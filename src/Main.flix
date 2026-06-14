use Bsky.Actor.ProfileViewDetailed

def main(): Unit \ IO =
    run {
        Net.Http.withBaseUrl("https://public.api.bsky.app", () ->
            match Bsky.Actor.getProfile("bsky.app") {
                case Ok(p) =>
                    println("=== Profile ===");
                    println("DID:         ${ProfileViewDetailed.did(p)}");
                    println("Handle:      @${ProfileViewDetailed.handle(p)}");
                    println("DisplayName: ${Option.getWithDefault("(none)", ProfileViewDetailed.displayName(p))}");
                    println("Description: ${Option.getWithDefault("(none)", ProfileViewDetailed.description(p))}");
                    println("Followers:   ${Option.map(Int64.toString, ProfileViewDetailed.followersCount(p)) |> Option.getWithDefault("(none)")}");
                    println("Following:   ${Option.map(Int64.toString, ProfileViewDetailed.followsCount(p)) |> Option.getWithDefault("(none)")}");
                    println("Posts:       ${Option.map(Int64.toString, ProfileViewDetailed.postsCount(p)) |> Option.getWithDefault("(none)")}");
                    println("Created:     ${Option.getWithDefault("(none)", ProfileViewDetailed.createdAt(p))}")
                case Err(e) =>
                    println("Error: ${e}")
            }
        )
    } with Net.Http.runWithIO
