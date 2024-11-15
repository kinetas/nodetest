// // i_friend 리스트 가져오기
// fetch('/dashboard/friends/ifriends')
//     .then(response => response.json())
//     .then(data => {
//         const iFriendsListElement = document.getElementById('iFriendsList');
//         iFriendsListElement.innerHTML = '';

//         if (data.iFriends && data.iFriends.length > 0) {
//             data.iFriends.forEach(fId => {
//                 const listItem = document.createElement('li');
//                 listItem.textContent = `친구 아이디: ${fId}`;
//                 iFriendsListElement.appendChild(listItem);
//             });
//         } else {
//             iFriendsListElement.textContent = 'i_friend 목록이 없습니다.';
//         }
//     })
//     .catch(error => {
//         console.error('Error fetching i_friend list:', error);
//         document.getElementById('iFriendsList').textContent = 'i_friend 목록을 불러오는 중 오류가 발생했습니다.';
//     });

// // t_friend 리스트 가져오기
// fetch('/dashboard/friends/tfriends')
//     .then(response => response.json())
//     .then(data => {
//         const tFriendsListElement = document.getElementById('tFriendsList');
//         tFriendsListElement.innerHTML = '';

//         if (data.tFriends && data.tFriends.length > 0) {
//             data.tFriends.forEach(fId => {
//                 const listItem = document.createElement('li');
//                 listItem.textContent = `요청온 친구 아이디: ${fId}`;
//                 tFriendsListElement.appendChild(listItem);
//             });
//         } else {
//             tFriendsListElement.textContent = 't_friend 목록이 없습니다.';
//         }
//     })
//     .catch(error => {
//         console.error('Error fetching t_friend list:', error);
//         document.getElementById('tFriendsList').textContent = 't_friend 목록을 불러오는 중 오류가 발생했습니다.';
//     });