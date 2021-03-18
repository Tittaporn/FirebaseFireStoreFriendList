# FirebaseFireStoreFriendList
switf xcode with FriendSystem using FirebaseFireStore.

## By Aron DevMountain
 // Send a friend request
    // Sender
 1. Update the sender's `friendRequestsSent` array to include the receiving user's `id`
    // Receiver
 2. Update the receiver's `friendRequestsReceived` array to include the sender's `id`

 // Accept a friend request
    // Receiver
 1. Remove the sender's `id` from the receiver's `friendRequestsReceived` array.
 2. Add it (the sender's `id`) to the receiver's `friendIDs` array
    // Sender
 3. Remove the receiver's `id` from the sender's `friendRequestsSent` array.
 4. Add it (the receiver's `id`) to the sender's `friendIDs` array.

 // Deny a friend request
    // Receiver
 1. Remove the sender's `id` from the receiver's `friendRequestsReceived` array.
    // Sender
 2. Remove the receiver's `id` from the sender's `friendRequestsSent` array.

 // Block a user
 1. Add the `id` of the user you'd like to block to the blocking user's `blockedUsers` array.

 This isn't a perfect and complete list but it should get you thinking down the right path.

![Screen Shot 2021-03-18 at 1 48 30 AM](https://user-images.githubusercontent.com/57606580/111584715-3b00a000-878c-11eb-8861-3421e6b22dcd.png)
![Screen Shot 2021-03-15 at 3 11 25 PM](https://user-images.githubusercontent.com/57606580/111584718-3b993680-878c-11eb-994b-bd6c117d08f0.png)
![Screen Shot 2021-03-15 at 11 25 31 PM](https://user-images.githubusercontent.com/57606580/111584720-3c31cd00-878c-11eb-96d8-24dafa9a0ba7.png)
![Screen Shot 2021-03-15 at 11 24 42 PM](https://user-images.githubusercontent.com/57606580/111584727-3d62fa00-878c-11eb-994d-af3c9163939c.png)

