class ApiKeys {
  //CONFIG
  static const hostname = "http://localhost:3000/";
  static const version = "api/v1/bailey";
  static const baseUrl = "$hostname$version";

  //USER
  static const signUp = "$baseUrl/user/sign-up";
  static const signIn = "$baseUrl/user/sign-in";
  static const sso = "$baseUrl/user/sso";
  static const verification = "$baseUrl/user/verify/send";
  static const verifyCode = "$baseUrl/user/verify";
  static const forgotPassword = "$baseUrl/user/forgot-password";
  static const signOut = "$baseUrl/user/sign-out";
  static const detail = "$baseUrl/user/detail";
  static const editProfile = "$baseUrl/user/edit-profile";
  static const changePassword = "$baseUrl/user/change-password";
  static const deleteAccount = "$baseUrl/user/delete";

  //UPLOAD
  static const upload = "$baseUrl/uploads/add";

  //PHOTO
  static const addPhoto = "$baseUrl/photos/add";
  static const listPhotos = "$baseUrl/photos/list";
  static const deletePhoto = "$baseUrl/photos/delete";

  //FINGERPRINT
  static const addPrint = "$baseUrl/prints/add";
  static const editPrint = "$baseUrl/prints/edit";
  static const listPrints = "$baseUrl/prints/list";
  static const deletePrints = "$baseUrl/prints/delete";

  //HANDWRITING
  static const addWriting = "$baseUrl/writings/add";
  static const listWritings = "$baseUrl/writings/list";
  static const deleteWriting = "$baseUrl/writings/delete";
}
