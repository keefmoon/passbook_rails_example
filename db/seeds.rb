pass = Passbook::Pass.create(pass_type_identifier: "pass.pro.passkit.example.generic", serial_number: "0000001", authentication_token: "UniqueAuthTokenABCD1234")
pass.data = {
  staffName: "Peter Brooke",
  telephoneExt: "9779",
  jobTitle: "Chief Pass Creator",
  managersName: "Paul Bailey",
  managersExt: "9673",
  expiryDate: "2013-12-31T00:00-23:59"
}
pass.save

pass.registrations.create(device_library_identifier: "123456789", push_token: "00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000")
