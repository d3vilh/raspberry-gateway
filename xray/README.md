

  ## Xray Server/Client
   #### Xray facts:
   * **UI access port** `http://localhost:54321`, (*change `localhost` to your Raspberry host ip/name*)
   * **Default password** is `admin/admin`, which **must** be changed via web interface on first login (`Pannel Settings` > `User Settings`).
   * **External ports** used by container: `443:tcp`, `80:tcp`, `54321:tcp`(by default)
   * **Configuration files** are available after the installation and located in `~/xray/` directory
   * **Advanced Configuration** No advanced configuration.
   * **It is Important** to change following settings for better security:
     * default password in `Pannel Settings` > `User Settings` > `Password` to something strong and secure.
     * default pannel port in `Pannel Settings` > `Pannel Configurations` > `Pannel Port` from `54321` to some random port (the best in the upper end of the range, up to `65535`)
     * default configuration pannel URL in `Pannel Settings` > `Pannel Configurations` > `Panel URL Root Path` to something random, like `/mysecretpannel/` or `/superxray/`.