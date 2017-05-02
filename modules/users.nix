{ config, pkgs, lib, ... }:

with lib;

let
  commonUserAttrs = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" ];
  };
  cfg = config.snabblab.users;
  users = {
    luke = {
      uid = 1000;
      description = "Luke Gorrie";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcsvXQs8U1TYZyGYLusQpOtBvmyvsa0wqxIUXrnmqIHY9HX5D0SYYra7Vy0b8SjNsvV9ywZZRi4b1BnKNG6Gxe+JMC9+mokBCYTo68gclfYAWS+x0DzO7KEPh9PeFUrYuUYekRaK42j923LBBMIQOwtPDhFzgRoYXZEaBCtUyCHrUi98b0CWL1uu0C7QfAoXLXY5l2pndT1tyxZnYg0rlohuhCDsniZZ+Em2mV0235lJ8l7UbvV3fASoAW4qEs3jkvBXwpDGKBJEoev6trM12FC4ZSiKcH7LBLxz2G5KCfRht46cXtp379xRBfAVI5z2WCegIGtRhNto591BRIBCmj" ];
    } // commonUserAttrs;

    rahulmr = {
      uid = 1001;
      description = "Rahul Mohan Rekha";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDN+Jf2p88GlKPHHxIM0laFQxYY1si+PAqAYhIu0/t/vShla8YAM+iHrwIwV/4G56aFxJHsJ15ysQWc5JSQkDCvzYiE223MAzub+vnDSpCm7+A8R65+8kqSq3RLzu1QAFXQ/Aaw2I0CMg4szwdFU+bxiApeH8rkuWBHuab0oPaZINPA0T1OfT6nr8HU69ZuZ0uYRIr38SR6jd/dJxHUEuSx/0HpSWypWA33wfuTMrOmcqn/jIm1r2DLo9HnDLu702oNx81f/qRaSwod91rJYUnIk3ogKaAJCEbIFyUqj1x9KgzUU3Nao74uAr9dVBGd/haqHXsmelLwwK57zi0HXt8L" ];
    } // commonUserAttrs;

    pkaz = {
      uid = 1002;
      description = "Pete Kazmier";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAqMh9z3EYfvGxSaCN/C/WH7VnvnJvfEoIy25Ee/rKBgifn0pWhK502v4+GSFzmSMrrl5SfklrzIpgXf9LCFHNx2K3uiAbNrUqfpzqMBHHB4r5345IUFLCe7dp7Tdd92dIMrHVCgp6CyGkVt2XgCzO4mRbXFWg9MxbY9s7xZb+3cE = " ];
    } // commonUserAttrs;

    justincormack = {
      uid = 1003;
      description = "Justin Cormack";
      openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3NzaC1kc3MAAACBAP2Fdv3WpJ6sVellvOx1Z/g92KiNVdTmk3zZhFwDHScCMxt2QALUM/fkIv7mJGk2IKyP66DwImIZmLy000PBVFna9ljhOutesJxRCh8jNUAc0QbY7SR+EkcGVwgLqW7hGUIFU3T320AtUmCmkhoPct3gwNVi/f7yICzZMhnsHktAAAAFQC4DjtemVp453YI2icQbuIxjqVI9QAAAIEAyBKs8XnweQLU6r5GOcnWnNjFkmLDHNdIoeXAFU4zpCrP71wopBn7jqOGv62HQCwNhIMf3fw0iT1WhOdoqqjhnxkLS97O5X4y01ZWviMyUEJ/v1lcxF7UKtC40ZGj0V1v1lWc/sFuKJ7gCul80zqDQSwtFr1XAxk66sezvUZRMEAAACF7cHXazx+7fXUxyLgy4aKL7R6+AP2zZJhjBde/4S0uOwLxurL9ap1TqAR1fdW8avchQ86zy7IuPMsrUV0M8KvEWIvxVlwpS/OQ88BTDb16AZpZXfWSi7t0B6cMIqEM/BaB9y+/0CrahvpOeVqgLCR4woKJAW9A3I7LUL6lq5bE = " ];
    } // commonUserAttrs;

    wg = {
      uid = 1004;
      description = "Will Glozer";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDarVruCoGwscDcL9IgAWneBcSfXgGq5F+mJcAW7zBmauOA0sSLUAs0yFazZ+kXpQ9B6lwLINcg/tUoeeYTqg1kX8U/+yjRa7uynISHh8yBSRn3oktvcjPCjfszO3iyXQ7jPe5EwX3r03k3POQExuTGV8wNro7f34jaQA0R8nhH7UUB8yiT6cq0AC/1/lTUgOoG2SWwuwLFKBE/RSIqB9zyR+4OwAlwbxE0SXmOF60s57Bv0E3rf9SkCJmiU0HNSaoR4DT3Tug/wWwf1MQOpZCgrNpBpgsW05eo7dEjwMpLRzRwXbvul6HnihY9NJslASskfI/G9WswSe2+67rBZF29" ];
    } // commonUserAttrs;

    javier = {
      uid = 1005;
      description = "Javier Guerra Giraldez";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxOGl1egCc4VvuMyoNpgj2v723aVD2kIW8XplbDQdMUscaJxNN7jNL2Vxe75iWMxnzTw/vQ70H++RCizSZplK95q0A3i7CC33TXMwfvI1eM4x0V/WxyXDrFOVNlFghb38ROF95c+4q9MLCXtxlqwcQ1Xq2+twQ/lrYoPNXjgOfFJogu7fETOURiqfgw2ChohGcf1w6NZb6OFd/XBavqiNso8ZdeKQnNBYOHrp4cpoGfZ0iUf1cc0jc/wUHEZGZZWCTK660uPXjvkxEdewaaZCHhhrQPqUUErLWSZizo6Y1YTBVAMjKKI6gdcpJbKgp1cxZM1YWDKmUI/z6kQghmVe/" ];
    } // commonUserAttrs;

    jeff = {
      uid = 1006;
      description = "Jeff Loughridge";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdWxznJSVvw/cxwGvJ4j7LgTHQ1PQtc6vB9nlHei2B18MbLNT0iSgzu7WC+2+dFvwSoUfb0mT0GiV/wGSAl6d51FWfFbb/mXTOcpeq7c0UaBXxjcX5K/DbjuNHQH0JP3md+ZqJnckM21nJLGAkVJGIDtdv3RXqFpBr4FZL44MXiO1QQdxWqvZstl6cB5AQl0z1SNpVWL8SLCxseAn5UinIVKTTULYgiPgQfML68D5gLFT7ZFzpEP5rsF7mLkYI6/sYxOl6DItdEnwh5C+P/pWS6IA8vAWYpYbFiBqw22tc281Z1TS0QlvReUuY/BWK91D+gZt7GlBYNvSzeG4YsPAR" ];
    } // commonUserAttrs;

    gall = {
      uid = 1007;
      description = "Alexander Gall";
      openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3NzaC1kc3MAAACBAOuCMNqMbu5cCTXbHFI40mBDsao9wkGHYVUV/bmCs1w4vap+pj2kY8TXZUi/O45rN90ZhWTa9HL+ptNOi5n02zN6SH3UyIRO5uQ58dJN0fPC9dn9uRe/wEdVwaQZOXnmuryDOPq0198hmimMWhUhPDL0hyCv31VB2D+rnVPHUTIHAAAAFQCC6BVJTwJV6k+icBy5PPqtvD2iQQAAAIA84QAgpuDRp6RbC47qOFQqGugLISgovvraJbKQB8z/bVlzsWzuRCl2YfG2MOnh26JusRLm9shDUHSzxGkXsWSPHWMhibC0NoeKG4sWoy/rPGsZLFltBEZiLBCnLXR/NKnUHNF/gg9Wx+VPWNz+KZMik00CrZmAVYrV3gcKtUFG+wAAAIEArYXur6MRnIUZ1vk9BOHcD3PN8JS4Ks592n7xUNbG837WFKMWm3MwsIsCkO7B2m1Qkkuvse9449UNMogMM3yaJM8KoRtX+AlFiG8DkzW0QjQ2DmGS1UPminZq2GzQRkFMANsOk0ketq9nokoRLjT3AVfI/kBIIh51sY1UKU5JEe8= gall@enigma" ];
    } // commonUserAttrs;

    kkielhofner = {
      uid = 1008;
      description = "Kristian Kielhofner";
      openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3NzaC1kc3MAAAEBALNdKl9b+PBQIEEUMj8TTChidWKietnkPZGw85UffTgILuSGNl4lKCRW5t/I2Ubeef7IbSqVFaqy0+P7rQ+IGqYqgIyaFIa74Aohb8cwECDXUl++nPU2o8oXz+3QIOl/RvQ/8Su7R7TGo7FrLHTumAItFn/zNmHge9zP50AoUDBZEyDYi+QJrt2zKmBFpIEiUjC1ymu22Nodi4mC/C6jS6ILJQT4/sBik2Zn43o5PGnV9OctUCEEiZQ1P5BK/ED7GC6XOV6BSCcvNfhdvQuEsjQDtcrGpOgGHbBxSGJ4zNCYmhHV71FF4tJBw6liBMZEV1g3HGU3w12jcMaqP7eoKD8AAAAVAKqcre4yE0Un18g0u0MVrQp0z6WDAAABAQCDULWYKqP6Alhw7xiIe3wtApDkuWLUcwOFOkj3iL2e5K9QiK6nBQCHB/icOaK4zEmZHLVZUFRkiXMbvTV+Nj6UTB9Qfo44z41K5L4XEiC685CB5IYyujNIkc6DyEGztVEPOJIjJFrsiA26hk+CM4s+N/ueUIGm6sZruTbvaUSWrQufJAe2DI00Xi3ocmPzh7vnaaTcwh3YWguodDy8r4nWaeoPPjWctyxYqrcf+Xj5n0hz+UG4YQeftAztkMx8b/7VGUihMLNDF6p4qVuXolMaieGKfvqY31tk/Bz5biQjyBXx73R4TdwiD9MydVlstXPKTnSBy7vR/0Yq0UMkJEEBAAABABEY0IbGlnUhtbRgZmu9cVnWSugn73aVxSB4uPokx/zvXq2Ydl0sphZGw1wwyEf5fd5uXZ+G5N6TCNi/+yBltiwYI9/UCAzYE3ALI4oHeCQezYdh01Ciwd4YcVVp+5dDNW2n7Zrr8FPqqAsuvBYZIgDj6YR93opx61bFMGuCw1hKSr33JBoZtEBR3wsIF9VTVb47va6bRKCzp+8WzDYBRpMIWhkGmO6bmHvd5gAexeL00RGIp1CJlcrL2+sARUfV+qqYMDYO5x7PgEbCVylPzZP5dDtPWJHAovfXedr66v8K1SfOyp19o9clcFAQk96bWL60vu1gvWRguDmCMfc02jc= Kristian Kielhofner - KrisCompanies, LLC" ];
    } // commonUserAttrs;

    jfenton = {
      uid = 1009;
      description = "Jay Fenton";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvqo1Xk7r6rb/B2ghTvKTcJHRcnsy7+mYosIjQ+mwOFqdaM+CysAxyIAKlOHtliR5fnAsrttYATDcrzauhzXW2tinBohhiUjLW1QdvO2mt2IqHrz/wYTzaJ0YqKJ13ngqj8OTbkV0Q4etCQqkF58BuVant8NC0owYuVSnRwJ4PWHTxTVXDfJaVO5BUQaImpfF/tLQcGN6pKyog57Hh8RYVUae9pcxKkhheoIoQi7dTyh11lwWrwfsqIETy3j0Mew3v27/xYREzpVSawZVDtuF9/mDPc+anY32ODZ0WlgFeWuGMxopazsTmOlKmbDv5g0R7E3ZWz8xdiMJJg5yyR+uiQ== jfenton@lap0.na.nu" ];
    } // commonUserAttrs;

    andychong = {
      uid = 1010;
      description = "Andy Chong";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEA3/KAsqRGAGH3QC5YdG/oKqDO1siBxNER41pAswY10XHq60mJ8EpBjqIX8tLHGUsvLzz4DFEC2khI75gk6DqnEgQQq7IHwMeBQ7799qX69szdmn617Ot7nqlocWHkeUpFV3GXO/QLIftwv3sfg4/f8osI6Fs40FgvybChn6YGdZE = " ];
    } // commonUserAttrs;

    yoko = {
      uid = 1011;
      description = "yoko@nii.ac.jp";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDg7IXEVsmPwX5Oc41d5F8HrpYj8LCWJnnLo4jfb9dmuwUgjUXR/MHeph+/zHsXVplBlLB0swQtxdkAgLMNv4hHHNsAK+ikvVFQrFm6zBTuZY8xVar72rHNkUi3md8O09rBhRQXm5r27OEkWQlTn0TtZ91ZkWkgv/zuAY5iV//SuPjBiPFX0m3JlDUG1J1I+1Y/N+/o/TUS2lyQcCeA/0vkVjUr8+NZs3zJor6TCQuWN06UhBbpuMs85HqD3hPatZhsDvC/1VhX2ocbBq5+T7JF9iflJCueZp0E1tv+p6v0j0KLTUcQnwyRPMKC62oVb+PEvNaA9iYEMNwNW/SwHLXp jxta@cn02041403" ];
    } // commonUserAttrs;

    max = {
      uid = 1012;
      description = "Max Rottenkolber";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAEAQC/zwFEk3x5wI0hZAr91DIWRL0YlWwBgJ0XoFJE0aRnblQ842Cg7cKAgNVnRhgBd8Wz1xGxAOOE0uTGuUs+2wP9/XAL82pjOg9gPqL2B55NnihK4MDykAzGrTZQlUoaVH4ukmiSyaw3W83BnLjg/lQue/71DYhmmWYYj5W1RNLsQMHW/7Ddp/3vJv+Ltffct01eQvzG809/PLz7hCTNFauWTLEWB6hPXBpVR8gMRlOaDzEoGo0/lTKPZNwbPTIGrdRWWhOXfF+JBEl20lS8MVFcC66aHQoIPEg4ADJtyNJMYB1lFH4Pm+fgeaU+j6d621ju45EWOgLwSw49EjaITKnnrrOv/B+lCeIbFEi9J+Whr77KU1PsVqSkfbqStoWOWIlQJmyhuq3FDUZaYj7LSDjbSxJhmqd+SODLz1wJ1/dP2mCdErI4QyXfbV4f6AIdDYXQ4s7R3XJ2yn4rdXFDnYhJgbQ/IZIqMpg1NGjeNBJfahzzMSZTItCMb1kyY6dCMruQiEr1RRlQkIQurYVkq5NrBg2DHbmA5ZmZvd41h58o34tEsCe9cTaUdmYoiA1PHCtsl4LaEOvsjzqr7mTdfT1Le0v1//4k65XpRf9peNxtyTs1c899i2iq7WLTdrssuPo/AOrB3dm3hcUIwqO/toHAN/vKHht4242UypDLJXEcXLQmafCEiI1xW9Q9ZbDTYCksJ20WzVW5LCe0CyXMyB/0AuRvnaTDbUANH+J7JKh5zuhtjBcmYzTFt8QkJjj4yRTTMlSxC6T2JvJxaSf25kJ7eHzt+zPiQ1QN7jECPpi5jpxIcy4GQk7AfbDW5DMI1SM250Kao6BLBZ5cI5fFIufMMmLdHLaWgC9tF/A5p0c+etvXMQFkdZ05FE+aHqVrabArHIAIiNfzKKDaGyTPh9X4s0f4lWeYhu0vlEU69JW05tYm+HP+1j1lARKwKlbQ509sxP4126irMtV6ksO/3IrryKlTFMaKax10fJwvfRwQkNjuYvd5I2CWN7oGinjggAO757nI6gK+D0WfilAPguS21CFq+9hyA2THs5KXfXap2dsqFmJCiu78KslcDmCTG0PwenBii2SrYuzddJnGjTk0HMZc26nj02XgoQhlaVOvjQYzx+8PPg5V6qwjcOhKRp4/7wwFWqt1twj4O3SBd1PhTFrY+SFfSaGNTqaeWiaLkQ1nN5UsNNTonLPiCj8gwsJKg5MwwOlFcPxyIjdXayQ3dRBiyyW8sRPHx/vyK0Xt3uH3dTBMt+oxTOlxj6s0jWIJ6zbsBiyATsvf8HwNeX1KU2NSrgUj+oarmuYKa+PX2+N0EKF9u0v9iN99LH/1/v4ilpSwwugZnWXwXdJeXjqn eugeneia" ];
    } // commonUserAttrs;

    byterians = {
      uid = 1013;
      description = "byterians";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDzCW2/OrSsiJQroxILKzY2WwRayNo+PAOBo9WTStSS1O6rcAzSTVfKt5EyJTjOTpT9lzvNk7yxrRE1zGZSIoDsFGYNgsRkfSCkIkO59SyHveEl+OchaDVqwn+Jl7XR5g1hDmhilwdzXpWfuvJ7XpZMgpZi6/bndnXbiiHrNnmRJd6Hnd4eQbsQSdEKyeWdZgxVjgJd7dGIpylgZtlL4vQM5Hhq48wdB4P3a71lRTHdyTdbolaCM7yCHwKcd3N6QaOmJrmsf/iAPvnXWVkfrlJM660hypN3SfwLsZPRDvYGXY7Kg1ulDBO1azQrJFmsdEq/JvHeJQZlSCXVSsMkHPlR saish@saish-Lenovo-IdeaPad-Z510" ];
    } // commonUserAttrs;

    xianghuir = {
      uid = 1014;
      description = "Hui Xiang";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPnTaAORQB9ZeJiRygykP609cpLYXLGBbURe/Y6m+lkMDaIUOobYqek08dzRhCVwRrTOgWQYL9HwTN5fRCpvV8dYcXjnvmWI+17TOmTdjxmpRKypLAnpuIDmKkYWIEsCHQxo10cNlUbXhMIgJSGHGnP2kgy1UQ6afI2Gu8onfBAP0UHOPBY3exuM1BBcVY4Zjg3xP1bkQyI6+2HiGpXBCkR0mjVJuqrSOUv0UyqXwcLWQ1N15sd0QwROW3WvuGAFl5XYbwJaozz7TeQIavdgiUC7e4Gn0Qr8iugqgzuylKpK/KnvWWWsAk34O/Sq4KiUmv/yEgN/0X2Libd0sh3qvD xianghuir@gmail.com" ];
    } // commonUserAttrs;

    anshulmakkar = {
      uid = 1015;
      description = "Anshul Makkar";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJygmBLFdIaY0SO7BbgBaezGbhQUKyUZ8RA0V7L47SeFu5evRfBb0Mdp3dGHhvDIxQfwFNDW6HQes1lW8Rf8RJBVXoySy5SBNddVgZNL6v/zZ7UY/m7TEInsY6PvqMz6KtnptA6xDbcQhDQPQOxv9oQZtgHYnOnnM7vY0XqfqjH9wGrfSftLPMHH/ijSewa1xhgp0TpS+7WLkDn0Cen9kxEyPoTRGUKDvRDnTZL6CAG5rGx9hzRxUH8nYsvrjciPrWtDsAu0kdMjHujD4Eb1qUgveh0Q7ZTMd3RXwYAVx3A4wRvccm+vaQYorf3NzB8gwp2Sz3+EjfVUgaDMzeZgwh anshulmakkar@gmail.com" ];
    } // commonUserAttrs;

    jamescun = {
      uid = 1016;
      description = "James Cunningham";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBE59E5AXlUqpSSHCS6TvUxPwuLadIBqrT42s3yt7PMAP5xPC2ZENXt7k4PM4gFQMLuF5kpiTT9claeSu+r+X0ydsrEpnesgqjoKOfHTp9WPIZuZdBXH97fxO8BF31g76Bp8HmZ53xWpZAfO+iwzvr/0yPKm8Ba3rs6OMaemd+zDPHrAeI1wn0LWYwAlxTSKl9IHRDZjv5t/3fj6h5STz+D/j9Uj5fBdFqnPdQoPp1CTfp6OZR9h3JTysH2OpYbYhlSje0YCZuavPfpkXGXVeqzqEoiJnbd8M/IxiP2hQuUQwOLW1bOnSKHXOldKITi/Ax1pH88onZYLEzIdWgmsi9 snabb@jamescun.com" ];
    } // commonUserAttrs;

    koriczis = {
      uid = 1017;
      description = "Tomas Korak";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDB09q11KKRPQDrioesdIQRst7FLZMmSNUBvS7GCvUapAZ253QMO1+akEletdrFMtnZ53FG+r756hWUG5157Xq3p2RJkM9/vI9MIovTM0SnzP7mHwvrzRThomZ600l4on8Xi/pET47dkV9MxADR/RAKo5cmc3N1/jYhB8v5U18AfDGYKBpqvp2yyIOX0Ems8ULFzNAnUXWqFWS2sQxZmVp69Y18gxYZ9iqtxEK8vGjLKkJpPnkyceqmVfydgoTCAHdpgmALgjtSmUsrvpCugpJ/1G/gAR6JOoxM75yf3/1lji/cWlUyeQZfa9E+yj6R8Cd3pd9BjwC14l7qjhP+JBkh korczis@gmail.com" ];
    } // commonUserAttrs;

    gnusshall = {
      uid = 1018;
      description = "Gernot Nusshall";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMWVJSlUBy6n1Cs6hghcelT57yNlSFyLX1uoiuab0USeFhIH8EmcYkwD7AfouVZMVQkEw7AFZ8tZYVMCSou59ZkkHDzIR+pN8/SkizyqOxRwHDxvpezpKSIXvF/t8NsAtV4f8Q78ZSvUFTio0qR2gQWgbaFCh3q10k9oEgtLNNBRnHKKGJRc+cZ85eaHZ4RCGgYPVpyAaq2/wV+ILztSlI96OqDodxH4ZCQOAwodeYRosiuuOL5YR7CW3uI1taiT1DI1RMo18JBXFePkNfEdRNiOiPSVsM2AyeRMyLcXMoOC74A7zKM2ziKfrAERpA1rCwPbzsQ4mqRI/UHpYGqeIl gnusshall" ];
    } // commonUserAttrs;

    ba1020 = {
      uid = 1019;
      description = "ba1020";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA/LBekkfhV02p4Jq+JtR74P0YuViJ7Bg7DcE9UPd0YlZEsMw7bfv4VYBHNHzCpr4krcICLfgRKkraQHJaAtcgOsSe9RDCtpDIVq7b0e68ASjOQlgKpF/X0uGdF42Q4kMg5PKr2PJZEfWc/EU9XuqEPzW6rvG9Wui4Eo27MjR3Ke4cmW8ZSvBfr2d/Ov59rMYnzW5jOtQI/hrcVboVPZLOUxm8FjzZ+uRKX/xbWIOYwU3lAzd6/5tIwu1acV3ik433mN5hUrug2OFXXmTuwr1JpuJ/hTJK330DqCg0GZIwa37IsCBlpM+RTAnTfOzi6a7CLShxLbcPjWjzsthVs3dXKw== ba1020@homie.homelinux.net" ];
    } // commonUserAttrs;

    garth = {
      uid = 1020;
      description = "garth";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAuS8I7Oruq49An5XIDdSRl8SeEHQzq21hXitYtqPliysJuK45cBGdEGtXCm5B2zfWLaduE8tRn5+qw8HPWO4vNSaLKBy1+oQ06Qnn0qYApeF5si0dZ/KVE0YGUPA3EsGVq8YoXUqKNU/ALEJ2g+2B7nyaE2zjOunHtAU8l/Di1mYKjz5ed2S92nvaeWjnaZkN2FwZDJbDZLtd1xga424p6mJ5NyWW9kJ4lygHekQ7PItHOXvgrLAiWIJfK0XfZLfhdeHiZAjokR9LaaOqcMnnHmVC4aJWO9RW6SLzu2HUcTNsCvl+4O0wW5gZs9+yZCwkkpnqAGRRy8uYvSYAYgdsGQ== garth" ];
    } // commonUserAttrs;

    bhaveshmunot1 = {
      uid = 1021;
      description = "bhaveshmunot1";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCycY6ljFkpQr4QkW0FFS1sjrxoP8I+CfVy0/eB4KWXxxKMzVQQmiVt03cHhBMxbS/Ioy/qncPb85HlcOjob/V2zJwpxXzwfhg8YLIbTAVVekEGlw4oaCi35mGlXKPUPGPXZK2Sg0HajwJ5rI9dEn4e0jrkaIsPZrO4qkw4KRrzTg/o429e0TCQrBBBxFxAhCgYJgcBIaQJniyVUepPlaQyVpvoQ5rh/IAzzfNFsrEYYnlwJlVtgPlmt4RqJYZAeLp7uFJNov6T6SK6L1XhFbumD1aiwL+/NY6sj0aJ9QZ0rt3FJ6l6ctUdEeaae1aMIskFWcA3h1Sp+Luu3NxsCDH3 bhavesh_munot@bmunot" ];
    } // commonUserAttrs;

    wingo = {
      uid = 1022;
      description = "Andy Wingo";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAgEAniIBKe3+toYN/4MtEnN8osjwkrlYlXfdRU1vXtjE1MRbPyiQ2D1MVFx6VWRz7VAKXToUeRqAqSm5jS+34r5erKbNGJnRcyOjryyDGCvwAHcVeAg0dbR75uwesw+0Bymhqw8CSCjauySWusMmB1is6Bow7G+tv9I91Pkky1WrgYu/JQDRpN00GCGbhrS2h2JaqIlgXRuzj9/ls8iJnPDNMi1qGoQBWXOhPFxURZMBPdUgFQeayQ96NvZdSHDlKCEgv9Nu1zvfpKsR34gwuC/V3/+DRvsRERXb3gLRQaZAPEAkAn/Qwu/SAMe7shgdKRiQqnpNsDGRWHCVX3E7QpSjqqmfbWaoKG1MITmm+4B/b+OWNThANCNxmkw+YSgqPnXcwfot5pBNGL/2MwdYLr9shidRrd2s2Sy+vLdaBlaaKSMuCIWt3JtVmj+yxXjJmHrnaj+oiNLTI/++La52smRgU9mk+0888Uz852p9WjeQ9C3dd07sdx96pGWDSkmUmoOaLxyn1ypIm5PvOoSZXs9/82sE5JUPmlVgPr9mF2vDYmydAo56uk9qUXD/4pdddzlWfmldsIoo4cAYFG+4tTcwOG/6TDeSWv0sS+9Gw1BBGvYLMpXBBn8TtRRt+jEDyvV2u7U5VK/h/wcPIVyiVXQkdOrkAOC3THVb8CUo+yWevHU= wingo@harpy.local" ];
    } // commonUserAttrs;

    dpino = {
      uid = 1023;
      description = "Diego Pino";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCogIewHPhYyqgNzfq4sIHY64EZW+qjaZUnTzwcsMkRVrgUowjnDOKpfcWVwhY7vf2q7dVt9WZAjFLqhz712RwfqWOxkGVkqdLV/7CjMnXfcnGIhof5jxfp8w11cE6S8SBFep4sS5iVoFB6QumIaC0TLiWXyYPYL5r5WpwZJPhdsvmfpTGiw7O04Nb/VC1V5m3VsRKa/Cc5huLsP4VXECG9nXQXzGemezC5T6+pKq8rk+QHQ7O7Z7o82aAKVqWk2Tjg8RiO1CnV5Oh7NPn2xYTN2ftBEnQPb/Nqu74WTjdf0NWMMnlQfeUytpElxI9WbINgOVn2uDMBK8Odn0pao2wb dpino@tanimachi" ];
    } // commonUserAttrs;

    tupty = {
      uid = 1024;
      description = "Tim Upthegrove";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0dHfnl833X43u1sSVX4gvS9P6sCpuEbYznI0fVzhN4a9cL4TY+zQJpE4rskq1ITdoAR66dazsLnddyGSLjY8zWpU5NfHjactB9h9AOTgVTQxZbpPROcn+KNEC63p4EzncqgHScWJsWcYPPsb2LgGGD0Hwhm7vmK22vaif2tob8v3OZ81U2a9icjWbK6tACIhrWIR36h0x1FXln8rTcftGs5zZPC2QpV6+7w4EtRXhO9jilnP1WMC0AuhydeInDzWi6+84808uetETu/3O9f6lvCO0hgKUiA8u8rjQyVAIhWmz9yLbkPo11Iba4laLatpjmWHCKVTJxsHniY9+zdyZ tupty@weentop" ];
    } // commonUserAttrs;

    clopez = {
      uid = 1025;
      description = "Carlos Alberto Lopez Perez";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjPKdDymf+ylGtgVdx91Gd9k4I0UxEY/Q3o9gPTwFNpwlaxuCQoWf4QYym3xnkBQDqG+vj8wC07FfsMhEihp6CuUod1kddTXP5XiXIOzH1VsiuFh6ArcE3+FzJ1c2p68iv7rA8XHjAj47z9DcX1oCDQK0k36PRxvHs156YxyMSJmAGdvhC2welJ0RN2of6b0HLpVUqjHFT0nesFrlTDrybP32oBPrCcJANH2Be+7vXsJwKs9sg7rWvvkT+jez4cUxM+BghbZL+ERtq7Q6BcZG++oln/xJLXRBXjZ61gShVc5kl+MwZpW207m5jc87PknI7GUws09otNMEEfU+26JGN clopez@igalia.com" ];
    } // commonUserAttrs;

    kbarone = {
      uid = 1026;
      description = "Katerina Barone-Adesi";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgt4ztMlTuVViA1Zco84FkS93/7fLX1QyAflFWGZvqhLYZNfJgeB5qHGcUfExl42+U5e0/Vu3l4KbBZJwlJS7xyzFu2mnKrcGSxg4JfCAzJWlWLBc4ATKYiCfZaZ/mqQOkLKNP/L6OCkcJlH0MFCko/u/eR1yKRmFzZ7jAv6iV2qj7XyjueJiDgoeQa4v/S4GneWsevnfoqBsjNRdHC2DnRV4m/dnzVTaSDWUjwVrSBnJ2liJzPeblNxdxy50Jxb5RQlMln0bVzJzUh/hDK98czPjxqRQYHzkXlNjqeExZhASIposZjSOL43VU17L1FqZz7xglUdWngzo/f2ZgXYy9 kbarone@igalia.com" ];
    } // commonUserAttrs;

    roicostas = {
      uid = 1027;
      description = "Roi Costas";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFNL6QdF65WetRIPTq1uw4t/RZrHB41T8+URbTWEqh7ffrKVc3KyHXn/CgsdhIuh1PDztyPhuJh42JJOPwlQ0ihh6aQsPKsiC99Y07wJwQcbYGWryTG1ZUV1gWKbW/+smbZx6n2yZUlhlO1JnjHA6tCPOU42+pGlNjVwKArIyMn8ppNW5bCU6u9WMpnlOBLJwR96yHDnJJJdM/3ZHan/Z88xqkxQr3T6MNH6TB/57jItJo/y8vg2s9V9n82vIkGHBkipVBbvXpA717oz6+6c5Vap+7C+Msk2Lvkxgma/YoUYfzHxD+vnHbaAvm9QYthRaDJw9GC4jiQN4DbPYYEy7V roi.costas@torusware.com" ];
    } // commonUserAttrs;

    kll = {
      uid = 1028;
      description = "Kristian Larsson";
      openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3NzaC1kc3MAAACBALjEzP27RrNkAs24cYqErHL4q8qQAODY3jFSgsXzCKk9IbEDlW8gd/5japWWQhfA9UdwncCWjVbBOWq7yEg1OTMgapD9cTJcUIoAwBRVPQwdoy75prTFFBfXjK4Q+QXE7cvRFmyou9ZcDJ5YRmXeod5By+i7ahQOF1EgPfk0EcrLAAAAFQDLNiY8d7jDL/MOZnCJneiKXFpSMQAAAIA9S+4JjcsqYbMaIV6PVapg7Ag8TSmhlBokWewY9xYPV5R+ct7LPZUiSxjxCF3DkN8+dg8M5vnoCfe1LoyD8M/Tr+iulTJbjSigW7WIKQpmwCAQ3ZZh+TUsENAmSWaKSxYHOiAqjs0OeDluKgxTYETgsoZT1eFt7xBChsJheY4HggAAAIBMcGyfNfaFv+/cXNiyxsM8IwbsEcRsmbp1Q5IhJ9efJwtO2kbWsxX79UgQgRwWVAT2eXDw/KPJOA5s5FSYS4EPhryIuKhDq1obS8FZn9Nkkxs6wDpDmTjk/5+xxJ0M7V4D5UEFCxMLeS7P68fM0Y3T5J3/EgtcrwvOUEAE919hLw== kll@spritelink.net" ];
    } // commonUserAttrs;

    vipulrathore1993 = {
      uid = 1029;
      description = "vipulrathore1993";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDakrgG/Yig1MoZ40qklkC4HYu16BAU8OtxUeGLf1BQ/OIChDx2LWvov34iCXe3MgifUXYUKAalaMuGnZq/FU11k5ceugI5ykYa6jfwO6b0ZEOc6Bzr62RfTdNx3UJyXugX5Yy5KtwH1BalDdVQrsjI3XoU3mvGE0rNe4Fre271hWBko4R1qkCkbPKmZzGJaexxOL07qpfJLVdJ10BY1etoVdfCgt07ocozxLSd/WLsTZoserjmxYQn1p20kDHMhpi0GrzqTwYN5lnYekDZAxzzjVs7VGhVQYHdPh3MDOgSsrrEUt672NVZOr1SHPlda7YUBF69h1wO+Ajn48AxTeo7 vipulrathore1993@gmail.com" ];
    } // commonUserAttrs;

    hcnimkar = {
      uid = 1030;
      description = "hcnimkar";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCV3IRHtAzI/20cQzJVv34AjBfTq8Q/+irCdScVSdmcmyaycZYTiBDuo4N6rcTCvLtoxrS6+vzPpcHKNLeUYJ8HzlGbvcwfHBMgpvpRdFcsp26Y2SKwkzVoHZzEEaRHfBaxEZweTRtFm8fOIoG33Pqp2Vi86BwmjyV2AyRyT/mRcAooKN34TSJ2GGKoSNV+sT+931DnUuuUy0kFtPr12bFZMj3/9uShLAE5G3UhdWNIFSXXej+97gKF0IOugfelMTbOAMiDLAgazgOHhPczlm1dE1pwnJh3k+neIlJwBS6WZ3g00+4QesSxpufTU0C/w0QDEGTQMphf2bO5t2QRVbgt hcnimkar@gmail.com" ];
    } // commonUserAttrs;

    alexkordic = {
      uid = 1031;
      description = "Alex Kordic";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQB3K1YEfoajRCiNLN6zBcf/zD2ZV4n+B85pjnPu6WeRO6E2fG2ea8TVSzfrhPICG4TIbX2C5hlo7UG1YBfl+tc3kktJqD0QsEZZnQC8KgFfM2mvl71svK0YxUoGQF30qKqpEVvmveG6o97iM7om7kMiplb0RTA9qlGekBg1/4Jxtlxn7qinJ1VL3cfj5hV7Cgs2dFF5c9+5A/Ymfrywmi9uamtiGRwDvb583vZyoaR3X2Z+GCb8WJsEaKnSQ/jQUrkO1H7ZQo2tuKk/8LLGR1SlzkQckQZLdq/j8oVwanp9zyCi9ZqoKya+/pueHvRzQ855kahFQb+zpPshoP49Oyft alexandarkordic@gmail.com" ];
    } // commonUserAttrs;

    anton = {
      uid = 1032;
      description = "Anton";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/53hJg7C18k0ATXzPp0E27pXdBa8/TpIE0zSad9C174wJGdcQNj/Pk9LwRCa6lNNGlDKB0Y3aQ0X4eSg05ZRnDwwnZFeSPQMTzpGiruqMWx4KQuHP64YnOYKiXol/kj6CPExb1ga/CLOG7e12efTqh/mJtg3LtW3f3j2j+DNvj3ErLN/U0Q9NlQviAPA0rKReJ68c65/1SgS1JUMeCoYXbLV1x6LFllIELpJct1+WN3qc4B4a83qaOGtQfharhOWeI0IFOX0p08I2Z7WPgwF2FlKBlPpYl+3gIBo0CPxV4ibJZY148lQJNIT7PmP/zcF6D9TAebuJoIp5jOmsCo/3 anton@ubuntu" ];
    } // commonUserAttrs;

    yyang13 = {
      uid = 1033;
      description = "yyang13";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDnwgQj+22dL8jW4IVQvrAJFUuA58wEdSebQ6/Ap8NP0ju6YWoSo504+zJfxL3yfy+1Kl/EkLCLR0/YFGGMHS7CtpPv67IKkn7NZAwfTNGDPQodT9exFz8lhT3PjBtuSgyXZin4vwMytAtCIfgengXjrFqJkq/q+efGvSmX9Y2tUXoiE7Xyu/+PBt7MBqxawZbON69XIkomjoo4eUUO48kyEhsGL3zpIPiBGHltpHVcnbNut9fMHQjynqaM5kB+3H6VFUKb1F1Q3PVGSLvwM/Hfk2pvOi9fyvrIig6D2cjl/+OsCdQkveeY0/p6fY9ThnUu/h3w+kcrc8XFVLkPnYX" ];
    } // commonUserAttrs;

    hrushikesh = {
      uid = 1034;
      description = "hrushikesh";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPC06uSKYm6OCMhPUnVY3ACY72rtKSHIEP7ltC0kehQZTXHs2/62P8Qx5xp2jHZsEhwVNYEnbmktElwRWz+FAr04BQYGCoBriJ6g4NsNuoSRIZvAdXUSjLNn2kOK98nXGmAiqEL7K9PIJAHx/ALhQ9KZC8Hc1ZtZrE/rUgyuqe4R39K3mLeFRahhPqEfEwUFAdcONYaCgrekpjzrOLKMarxZo0rxj4qj9HztQUQ07ABQEoV211jj3BDryMoyxjbGLVVHxhObQ2rR/2ft3Jys5uIg0yi2nxfBJJmU6tsdQd9VJCq4/g7ugNpPOncmP6SNpiAMJ1WCBWhNrmJ273Byt5 hrushikesh@hrushikesh-host" ];
    } // commonUserAttrs;

    saish = {
      uid = 1035;
      description = "Saish Sali";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAojLRy4jjbQ9d2lp3UieKs832j8SACUVoLIlE7mB9+MaXSptSYt4Ucey+Bz+0NaNX1JISBd1D0tF+AQM7Rlm6J0p6G/37sNqarEJzKpr8gH1tEpwt6lsebdRzSY91jxwAMmBtUJgt2BufVnLLeLs7sxJr3G43e2R8CgoSYQ5OUCXiT2oV1+m+0LzWs021gqjmrhykvG6SnEn6MrmaSH/6qSEc75mJXaeiZOzWMpncrSav0SpIM2D0nnq9qxwOwusJSmPGPMMC71VvEmP+hR6DE7bKaqW/KNqyRK3q1R/22uZvr0wQ95E8UutRVjg7vNU7rgm+Xr+u4SXfX2iGdLK7 saish@saish-Lenovo-IdeaPad-Z510" ];
    }// commonUserAttrs;

    hans = {
      uid = 1036;
      description = "Hans Huebner";
      openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3NzaC1kc3MAAACBALCWUTxnJiWIwo3sJlF8WVi78Qt4lNzeC1rE8ioTseMvt76PSPBePq7M/W8jJurhSVQG79D3/+CNmHmgXar0ZpHCwiRBZyipCpqf8bVCytI2CGKT+tMGbjaxLdNIDt+9W+xInv31AaNWdUx7huVRlq6unbGqKWwtUfzbQX8HNWnbAAAAFQCS7+N4ZDLdCGAxpLOY+JBUz90N8wAAAIEAphrgNktQlYQTUzopnmy96bzkMes8QmdAjWSVvm6yce/uCpmguo0HODHb0Az5GCgLBSaDFnjbaQ3jcqQ2PoH6zgzdbPanwpcrjy7/cishhGEZWj9dryvvEUdmls356IVfiRjUF5ZxLyhLvwkGoLI8aUaXaRIGd88oe39O/8XderEAAACATVVl/MbtbjkvGV1nnGpYW+D0v7OvS6v6x0gknw0z5cZSyjjnAwAQ9yrxaLsIE5BSGTPdZqxdSSosQWwPRwNZXeZj8IKHbQOMfkhdws8ez2JinJ2Mgm2hrtN0IJQOZ5ICP9ER1XoaU/EOT4ib/vpYLYSOkpEow2LCdBl08mopiSY= hans@huebner.org" ];
    }// commonUserAttrs;

    daurnimator = {
      uid = 1037;
      description = "daurnimator";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAzg8e0cW4io7PVp+ID/f8wHldye9eMXv3wwp1TRpoL1yvqkXkou+ri4dhk2sZ85wfrFQKG13eY4LXYsPGlBjkrio5H11/dEzTGM5VkVnHhEmE1zV3szV3vf9zdQfZ0LPyNkeOf+Mec1olDgpMnLLv+zb7CIqGEzRvZT9dYTfiVtRizNGAq9PB+V3cNcA325WFQwx0o9FZQCbvyvI406oWk7NWLBv9/2YcMNUtsuzvF5ErF5W4wHuk1rEhavwPTW/r5O/97C1USrMdAQVS5AepLEWjlp7YUG43wygTLY6lk1m6oYd6FcILyjKzUIbdvBWnlTSbxaiyM5gkIGCgMcDv daurnimator" ];
    }// commonUserAttrs;

    liuran2011 = {
      uid = 1038;
      description = "liuran2011";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqb4RqdSdDPM6A20l2aXjG4v9K99ogsr8lpBGHHl7V2Ek00mrS3bS4sCbvp3YfUFNMZfz+8Fbbl/KIJJngISAw4QTcLMPoUSVfm0H23neJ+LeJjfC6WFlF1orXuTothBjhXvGmEUnpdjfMdA+qNDGNRaVxKBrlCQR1j3JtBzPKBSk/4tAKotOfNmiQlzWPCU7Ea7f96m4I5kimgnuUcFQvhSR+t37JYMeTPu/e3j/nuzVf8dk0yeCHtVvw9CiT7lhho1B/9bM999xDR4scOSBWna2rLrFECn7Ao2d/PoQ5wZE2DRyfXRtonH053VE15Jpc+LJI7VOWXnFONWym8Bu7" ];
    }// commonUserAttrs;

    sm101 = {
      uid = 1039;
      description = "Stevan Markovic";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDmUqhU3Eg6zPJ8MEKpCcBkYRHXd/FVBxmy0DOj3GD5Hdxd/+cBDk/mfIJOy+r4HG2qQJBls9EvvZzcSnF3mqqURfWUDfKJ+fNZ+0vdeTodmgHiOERO5pUyf4h1YxqbxX+cVfELxpPwkGjtWIsvdt+CKuQ1b1rauKgv33YVkm1VJHCBJk8mh/JN5jsplnyu0nR5sPOJQ8rnDOr3vRGa0nGc+G7S03bAUBTmgjbEsRUOG2TJ1TPmkXoCVlR1I4yWUmgSMiKAO8nOFEwQaOQbLhLsvcYF7T4KzF86BUIG6hkm3qfHLPCmdbOfXfFnp8oNZiBq/S0nrHMLT9BGXjfXdbGv sm101" ];
    }// commonUserAttrs;

    kellabyte = {
      uid = 1040;
      description = "Kelly Sommers";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIYvOmMBJniB7gPN8wO5Fla2JpuWZSUdhkE6IengiKLB9H/fS7Uu5GoT94CHOa5gg891eeM/MRDNGW+C+9x5UWbOiioaZoICQ9/srnSGHEHranTUL/z6AAJIhfRk+aeTdu7HI+wZv8ukMLWPyfsAAEcLQAK0tD0Nq8xqez5XloumASqzV1mPb0hHWlGw/Wx/Z+FJwfpvBkKULwWzD8kzFQWCBXlsk9vvQKgT4QBCXIjsvvAUhQLkkrXJI1Zi8G17zimcCS1TxEv9VPcf9vqTR9JtDawVtJZFIrSoi9SYDAoiZtR0RQ5dttbcL/IA+IFqBrRPygSLPC5Up9B7MEJ8Sj kell.sommers@gmail.com" ];
    }// commonUserAttrs;

    mwiget = {
      uid = 1041;
      description = "Marcel Wiget";
      openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3NzaC1kc3MAAACBAMdlCk1NNT2O+np4uzFWFDHP+zTS8uAC6c0mv2miSgAgJxFyfZpJH+HbOuLALCoyPrQbAPb+yPeXvl7xQwAUd94QW3dsX8B70skaxGQMXJdvEu3iDSnpxdeNMW+Ctl4JDHwNoZ93dCxqUqiF5tIE9ock8r1vEZ4d4Xy/LWe+mneVAAAAFQCZ3YEG7uDAfKRxcIK7v4XJyCknCwAAAIA4l8xAexLrEiheg8w8YYGvTtTV20xDaFObLI0fWFpYM0n6g80xkGoM409/1ne6PPqOydCp6dfNcbqf2vCq2WxffjEetMSE5BNk02JctdafO8wiGVFnQd39I+n70SCU/48s/NX+RqWcRgTlwDzp034ZiclDrmrBGVmz5TAJWXT8BgAAAIBbYv/+kxyNdM0HLiQn6/ShTCqK6gkhumDn3a/SS0nHx3LpdlACX9x49a7VTf4tYqctW6LUkE9ei0cvsHWq2ec6Q00UAypCaTtwUjt7vr7HmwuTKV6XOsLkupnEED5jtRgeEz5fuWPIMH6Xg/GENJ5z7N/6AlaOz3Emu6TQtkdwPw== mwiget@mwiget-mba13" ];
    }// commonUserAttrs;

    nnikolaev = {
      uid = 1042;
      description = "Nikolay Nikolaev";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDc87+h/CtgYjY0YIVqOAoqSCSmRdBevs1VecbZiw3u7HT4MkKEvd7ycP33eDYEL+pkMtEI7FVwZC3UoQCfEX1Dhu4TODzOUimgDawAej7dDYQ++K+3jUahDjnh+PmowTd9VTO8qjRJpJrsEuFBBOjK4p59H7VEh2JO08XZgrB4hk1NKgL2Jbal6zps6j6+gj5XvEjROOE5U66YXZSfD/pesvhId/XrQTs5baXSvF1d+Hdl7iKMsB6u/8i/g/+Xh9yPlgIrPw1d4q4jiQ1uKvtIGybhBjTRkIzD+RSfRyNpn4spFlT2keCtsUT1pBdg+0Bos3PT8oC5qxeLlOjAKDiL n.nikolaev@virtualopensystems.com" ];
    } // commonUserAttrs;

    capr = {
      uid = 1043;
      description = "Cosmin Apreutesei";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIBNkVXq4TnTim93FeXi15Du+EkY3LkNvNRk2qKWW5Cbiv8fwqr3fxLwAr14EgY94mUEetLjj1yLXuIXjDP4PnybTA8jY4ejCoqLHX9k2Uas6x8ZDTtIfGOH7l0F8Wo8x9QUwx4jpNrnOCRjwYKThgeuvOFyiWziFfR3rvYO31bMWw== cosmin.apreutesei@gmail.com" ];
    } // commonUserAttrs;

    domenkozar = {
      uid = 1044;
      description = "Domen Kozar";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7CTy+OMdA1IfR3EEuL/8c9tWZvfzzDH9cYE1Fq8eFsSfcoFKtb/0tAcUrhYmQMJDV54J7cLvltaoA4MV788uKl+rlqy17rKGji4gC94dvtB9eIH11p/WadgGORnjdiIV1Df29Zmjlm5zqNo2sZUxs0Nya2I4Dpa2tdXkw6piVgMtVrqPCM4W5uorX8CE+ecOUzPOi11lyfCwLcdg0OugXBVrNNSfnJ2/4PrLm7rcG4edbonjWa/FvMAHxN7BBU5+aGFC5okKOi5LqKskRkesxKNcIbsXHJ9TOsiqJKPwP0H2um/7evXiMVjn3/951Yz9Sc8jKoxAbeH/PcCmMOQz+8z7cJXm2LI/WIkiDUyAUdTFJj8CrdWOpZNqQ9WGiYQ6FHVOVfrHaIdyS4EOUG+XXY/dag0EBueO51i8KErrL17zagkeCqtI84yNvZ+L2hCSVM7uDi805Wi9DTr0pdWzh9jKNAcF7DqN16inklWUjtdRZn04gJ8N5hx55g2PAvMYWD21QoIruWUT1I7O9xbarQEfd2cC3yP+63AHlimo9Aqmj/9Qx3sRB7ycieQvNZEedLE9xiPOQycJzzZREVSEN1EK1xzle0Hg6I7U9L5LDD8yXkutvvppFb27dzlr5MTUnIy+reEHavyF9RSNXHTo57myffl8zo2lPjcmFkffLZQ== ielectric@kaki" ];
    } // commonUserAttrs;

    hb9cwp = {
      uid = 1045;
      description = "Rolf Sommerhalder";
      openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3NzaC1kc3MAAACBAO92/aGijCVcucSmnK702ZP+9ayahp2eerK/ykhyfMW7YCK4oPTmwWM3wdl0QULMtUDG1O5utBnI7JSk7YEodAmJy5V1C38xqd+vBM1eHylribvqrhi8F2QrFTVorcI3ZMcnKHwxq9JSmgQewKGiTIsE9Q0LlQWEsX7jViSFjTA3AAAAFQDLcnzCTJmO5udub54VEjIsGuWyiwAAAIBKH9g7NaTWpfZQAsbpM/0Q5LO5uuwOhHg5E33hOZ5r7C+Mxn1X5x7lBaQGlvr0eBuv4zwytJalfuuu9GVPptkxngPr9F8QWbRXsbVD0fmgIY2dEyW8fUd71JXLq9rUBv2odfdOatpkkC8Xu4WReFN3V5UMfabkNp4fkH2RT6CeJgAAAIB75VEM8lCS98XZCs4J3zDCHSz1BiUsMvX4+KoC1HpLYiBXfXu0R7v031AkvJXsRs1izunMOsnpeGT8cE4lVbN0iXgj+TMEGGyexqYScLP6/LEYiBn+Sz+9U6kbccoaBooOvMGqsMqo5QSWDNewyVhfVb79TJJ7CEVha2hX66udKg== rs@greif.maur.crosscom" ];
    } // commonUserAttrs;

    petebristow = {
      uid = 1046;
      description = "Pete Bristow";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrOPZ6znKltSSFu73PcRr0jwi9l+a3ci/HiKdhKY1YMkMB/gEoJbhaOVgcdd9P1I6pagax5Xr28RxWVBcUMJNYCc1Oq2P2piAuknKAOFCDujj7ZIUXbc9rY8o4wHdkHHJHfvTSMVmGN4l4oGnuJI95ljOwKi69cQAjc6C/Ol6fa9Y5Mlz8PNUF5twX7qPmdARMlBNnHIEZFISnzhM0HhIZs44gV0B6g4JtSKyFboqKYZjutMrEnoPMLygK2RH8wWQ61jQvi4c2jypZ4MMxxnO+Aw4/fCgQJ3x1bBp7lUtiLp6Yz5w49NQJ5tKYApNJEzq062WAuh+PrqNfdo/i5F9uBy0P7KZ8e9FGOveydqidBzW2eV2c3nCI4jCVNsNm/VAB3AXp2ikz4JRsDvVqWNbwKnIjQdcuhT5+NuRS6+RoTG5tQ1Xw8ExIT8d1uR8+RwFD0jeHbexOKYZmMCwPGyx9ms+1xF+j6ncjkqlzHAhKUDzyI+8VACfemLsBm9tO1HsEqBx1w2YZ/s+UcCbrTpsE5wJ2Ny8qcHPl8NgFkBR9VVDyPYojhsRyfafQV1y1Ii5Is8an+TJelni1t3xC5hPpqZDWeGv6E6btFvJzfhv33J3/1xxF7inou8NK5dhSkBE5NaUdUjxu+847Df+aKeR0Nk99O3Co9fGENw7EyVZzCQ== pete.bristow@gmail.com" ];
    } // commonUserAttrs;

    farinacci = {
      uid = 1047;
      description = "Dino Farinacci";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA2ymCHUteHoztZF0oRmVo8oPUSLBb0hwu6gvapOJFizEIA/59Sj9YIz4p6HJfbPuAnjT+ROL3J7m44maMUjTzLKxsjorSjOMiujuCiSF1YFnCM+85uR59X6wL+hLI5lw/kTpu4l4YyQmFTLLAfIIr1G07+/kbHFOWYaNzMnNjw2Z+BsEfhQmHs+QtM6xgX8UcF9e+hEY+oLhTLLokRYvi89mMhPKpEGfvN8tjuT0cMjbKKAaEfPRvmb+AMfKQda8fHfSHBzbkYma6mPA4sByoeNLo3adf+Z9Q8ce0t1LJ6zZ7pGNg7shOKJNrq3RMs194i7WUayqDafGUt+/ob/1NpQ== dino@dino-lnx" ];
    } // commonUserAttrs;

    ciberkot = {
      uid = 1048;
      description = "Konstantin Dunaev";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDeYW1j7oIqonlmEH6NV/iQ1GrNg8XiXi7jsaT+hEUNF8yocCyhNlv2cjdOC1GHiN+GMR/WPH24J73fPHpA6t+KSKUu5psOGnxJj7aIBrb4lG1h7XWUt4Tdbp0Ql2lauT4vpXXE1/1FlY833MJLRZrQIlFfjGiG65vgCdnRKMhVXQ== ciberkot@gmail.com" ];
    } // commonUserAttrs;

    rme = {
      uid = 1049;
      description = "R. Matthew Emerson";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC3jDHD8TRiCmlTEVXtUhoRF5m9NFfpYWpSGwqxJvjvgWsxWME/wvYeiD6rStqf9KItilQnPznXjTKKcLttga74Ea26Uf80jbfwT4TYPJM3n/yU8Sp8DhTKiqBAg2glOL4LOLlkj3zTT+HDV8pMbqXaOAs0nE1l35qYy4ab7czOhij6gJsSK1lkRVj1s8ieZhCm8g/iF3d1cc5u/07ZIBgfm/WTTx4nHZMXItYJz8rhOCCXTplFx4U42g6wM7EJETLBIwtJ1XM3JFNfPLJsBONAoWFUlRt/T45t7FxJkbc4sYLfB9dOQfEpHpaT2M5kczNjYisuu/APLIn3uI2RrAV rme@nightfly.local" ];
    } // commonUserAttrs;
    
    turchetti = {
      uid = 1050;
      description = "turchetti";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDq55S/9rdsGlgYvOfCRKeWt6FnHHfNb2YJWAb/0nPDIrarLKcjLS1xY5KeDaaRPwNFPRQwRmFV+4EHYrLrL2AdEPtGbQZt737M/kXsfLyUZ+xJ6iBxKloxeCwQnVo4oCyqd7ZHhkLb0fxiyf2+uxxiCfVzKhZ6a3ANBw8Ne8kjq1aEG3JCvST1AZfsu2NrSFRGkXuKmJVbtmLXSdu/3t/5ckYg2dBqsXdIbv4kINpVyJ9+4mhRkrYkINJQkY6QRzSCyVaOMA2qKHdNHSmFdGjzIRyiOaF5ojejNB5w1b//Kar60/I6R49sokyvnW1/OX7HrC/yLbxSrvbjpJt54TpJ" ];
    } // commonUserAttrs;

    lperkov = {
      uid = 1051;
      description = "lperkov";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrGEnng+UYO7EHym1tN74B4mlTWkKu+JftQjE/AZ0kKAumbipi/EQ3n8cv7clnraSVrNAkaX4DSc4t/8t4Uj5ItJsLsIVs0l8ZqdR2NOUZXZrPvPhwf1q49e5/rT+PbW7uZBEO2Zf7xNzT5x+LWX6EYWz85hKxqMzDK72SzCSCUo3ntbrxK3ZeTCt4JAXsFefNT1Ek8BQksn7tOLps7zvp2vQTHqLwacP7hSZL91xT78RRzr7/jxVD25oaBbdkbJzN/wibsq44mDK3x9ECSEZe56AEoDLI/OGVlIj9/lY6qVRwgeYClSUvlykTjGeQINZoPgbOToqob9o7/jm+FR6+NiKbiVf3dNQ0fP/G37WQQBW9mXP6a7EtfIScjN0NHsdOjxwn5v6O+NbkNtnbpMN1vxbOcqDmntjNCSVTF+eTMmvtyjY9VWp455UkTA7JrjdEp9n67hEUyZgYCAc+Bp/CSvnb+9bb1hj+YbRBabGOSEXIRhflRrSIzsWoZwlogqmDpSQK+r54gU5DTbArUzJAs3+dCJGlvOoFV9EobWkC8XlXSfCztAiITDIKhsE0AGgm9O3BlZZlURTKTGmaukO2gkdCKQ9k5v9Vb0kvRooHyF2d8wIzbBoihOrv4uBbR/NtqvYocVUJbM6JWHcw8DCAO5XhBGB2Nh14mhKQhLh1zw==" ];
    } // commonUserAttrs;

    mnovakovic = {
      uid = 1052;
      description = "mnovakovic";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7hLoCsDgvTYyjNYmAQw8zLN07125FXKDTEcHQSLq3UyIoiN7Yu0PI+Ci6rFUO6VD+dkRlMrDt0rja7OJHNN26N7LlMyvuoGICknIcaz4vbm1iwEihFNMgASwDNf0ZkkkWtnJULhxHsLGOjHVgbvOAQWbxO7hXZdhM6BwXnLYBTqfEhY5WnDWuGZl/goVCArJpHIqcnHDgjKJcmKZIOkCHEIZPxiEuIzuTj6XA4HmFaPXpLnh1d6Vx7H21R/aew2ffNYTxjHY/Z8qdwF860M3oF1tdOJixMG7e8Bfhg116ilW6u4Efjei+b1cqZD0xXfTbO/8PmxSrt6FxZh35ReoNN7valXzHNhfx8tXbBSx9hx1JyNjCNIzYM2P7pSnVY9WiZvWn5ZwAE/uZdPnSxJpGHw/FF4tjPnqKOqwd3gEhIkpnm3Wqo11xW8Iv22biXiQC9cRWa7ivBtkTiswE4jzaa26TekuOkgINDZEBe5F34SQUHQ7rjYs4zOiZn+3JwmBZuaW+SFLy78NBlSNlgdduCUcr0juk3ylLts7una2KxeeOloNyMrBtqqsVeBKLP0JLcGCQSFpbO/7Q9elWe6ZUpdAl6Zps75KzfjGK8oFvDcD7RP9EDvJkR4Rzgy3zedD8DmuExFX+bUczT0hMZDPWwXhWF5NyRcC2zVNOpkAwCQ==" ];
    } // commonUserAttrs;
    
    fstd = {
      uid = 1053;
      description = "Timo Buhrmester";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHWqm10yU4MAbBgIy0VaKmJGNAukgJy6PpouQWQsazzbQ38bUalwAyxrZszwyf9fTEMyfrMmTtov+RZYAAtJueOUZu6tz+oqng7TaOpR2Ge6RBawFIQ+ER3mlRGi3nsw5+RME5wV1OAcSOyFOE01w+aegY0pr9RKUJLfGvjByZchm7khzrk0rrNODnztDhGSTMbo2f/+4MvtP0OP6Du6dZ299kSW1DbUbs2RrSPp+lHZPIUS/F7GMqdYWFSTtTEmw9ToxUU30tQhF62cQDY7BPJksdgjXsYqcUBQF9TafdySMKtm0PrstB5sKmn6CvJ2TbMWvHyE7QTo1/Z471yjrd fstd@grapefruit.pr0.tips" ];
    } // commonUserAttrs;

    teknico = {
      uid = 1054;
      description = "Nicola Larosa";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA38vpLAa/p3w3qvuD68cR5azEIlHngJ9lVrIldq4JGpq1nP5PUsw+zPvlTfKIP0S7vt6MpCf+2cRQF89UcLMoPE6J2+cg+pSQ0dUjyNn7bJ0EDxJU/DmLqdukxu8d6dC/IV5TB6G1Q9gxwqmDY5IrSEjxfEqb8qk1kY9mFS2epZEq6VIxxe7cObk2VfM+5XGZOfTd7MflWPbL/OEeutspF42hJaBm/6IsyCEjOLkJ3MS16ARTGFReK8DtJL3EfiKVKTJCuLzhTeqxkrbctQ0zRcLQ41agbq2vwSI0YtP8fOif8LTwpdWyNq8TEPfMqx33B6fe/i+hkRrthiLW9vb+0w== nl@bluethunder" ];
    } // commonUserAttrs;
    
    pnoom = {
      uid = 1055;
      description = "Andy Page";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCZ55DNWDCUGPa+Y2vtlNscnyIqtZWCv1S3Owxw4YOyCHenFMJqENv0RN5tY388OBHB7FAp9POQRsl0mVefRopRgtU5y3u4ZUm3JKYNp/YbqS2ohP5fA1Q/355ciqCdLZ9z7dhk0f+1NYte7UekElW6HX9o/rAJ6JbgFUwpYgE6JHOK2VGV8AZEvAe1w8p7FRVtQdvN+EWF091sFwqUVBdlhxQUZslbDyJfnO8X4xqo1hgfRsnjqbJpbDYybqnj4EhlVZYsdbnZLuFIrvkZF3nTjNsPHvYO+WQgym39HmyMGo7mxxpDfO4YAspSorfCKS39xeUNT/O+sBbRQRBw0IuwkhfzvCr1F6f86YE6Kmwehb++Htm4qU66WLTcdm4WNoDIysQV4gzzbXKnmefwykY8F9V1H1KkrXj8OhPAd+iw+lXH3txVcR8r4v7lirxHJ+A2oNuh7DCpPTNzvKdij4Z3qAOMpNsgnHjgsE5FxdcmIKsMpgIX3ngX6wovOk2jllQACPXCVVkUI5izA+0zRXR7f15+t4SDw/6QMSa/nC+Ds350D2sa4tnT8dsQBLN7q83GjQ7B4ygaeEe3TnkIqCO6tdVWgMlq/nQjlgRYx+5X2+rYUFGL12LSDJgor+lvaMTo9jsI1qSJpKV5H1v4uxJgrAG/Tj5fcwsVdOHYhqsIkw==" ];
    } // commonUserAttrs;

    miguel = {
      uid = 1056;
      description = "Miguel de Val-Borro";
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC33oenrfd2w22VkK/ISFTHhXX/F3UgzXBagmRigXGkmnJrNm4y1ykfX9dn0Tghx1orlrX823SgoC7EM4fiCJLrXlerQ1z5kKU9dXMLIFPcJbTu+kigMJJaoM+ErAw3M7MWphNJ6gauD43PPjXWdCby8sTkpgAY+J6Vq5808TPWIePE9S3kJr9lwwgDWG7esDJHoOvmGx7BPLUIxWGteafRW8HKZs+DZftUtm/qzwEDv8SWwmuqzv5edKo5xX3CNxQ9Zw7PkRI7MyWNfmiUsAqPyv86uSQrFa/eDjbIkMf2+k3p0BaTuCYZN0QJnCqIP8Rg2hOOE8xq9nvv3JRNO0CB migueldvb" ];
    } // commonUserAttrs;
  };
in {
  options.snabblab.users = {
    enable = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Add all known users to the machine and assign them sudo permissions.
      '';
    };
    all = mkOption {
      default = users;
      type = types.attrs;
      internal = true;
    };
  };
  config = mkIf cfg.enable {
    users.users = cfg.all;
  };
}
