/* Moralis init code */
const serverUrl = "https://x09y0dvcc5zl.usemoralis.com:2053/server";
const appId = "jHvfJUavaLQ1rsmkkB1JM6ctfWXxxqXFdvRnIWmd";
Moralis.start({ serverUrl, appId });

/* Authentication code */
async function login() {
    let user = Moralis.User.current();
    if (!user) {
      user = await Moralis.authenticate({ signingMessage: "Log in using Moralis" })
        .then(function (user) {
          //console.log("logged in user:", user);
          //console.log(user.get("ethAddress"));
          userAddress = user.get("ethAddress");
        })
        .catch(function (error) {
          console.log(error);
        });
    }
  }
  
  async function logOut() {
    await Moralis.User.logOut();
    console.log("logged out");
  }

  signUp = async (email, password) => {
      const user = new Moralis.User();
      user.set('username', email);
      user.set('email', email);
      user.set('password', password);
      try {
          await user.signUp();
      } catch (error) {
          const code = error.code;
          const message = error.message;
      }
  };
  
  
  document.getElementById("btn-login").onclick = login;
  document.getElementById("btn-logout").onclick = logOut;
