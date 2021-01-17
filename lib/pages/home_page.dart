import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_air_new/models/radio.dart';
import 'package:on_air_new/utils/ai_utils.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyRadio> radios;
  MyRadio _selectedRadio;
  Color _selectedColor;
  bool _isPlaying = false;

  final sugg = [
    "#Enjoy Music",
    "#Fun Music",
    "#Rock Music",
    "#Classic Music",
    "#107 FM",
    "#98.3 FM",
    "#Pop Music",
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }


  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    _selectedRadio = radios[0];
    _selectedColor = Color(int.tryParse(_selectedRadio.color));
    print(radios);

    setState(() {});
  }

  playMusic(String url)  {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: _selectedColor??AIColors.primaryColor2,
          child: radios!=null?
          [
            100.heightBox,
            "All Channels".text.xl4.white.semiBold.make().p16(),
            20.heightBox,
            ListView(
              padding: Vx.m0,
              shrinkWrap: true,
              children: radios
                  .map((e) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(e.icon),
                ),
                title: "${e.name} FM".text.white.make(),
                subtitle: e.tagline.text.white.make(),
              ))
                  .toList(),
            ).expand()
          ].vStack()
              :const Offstage(),

        ),
      ),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    AIColors.primaryColor2,
                    _selectedColor??AIColors.primaryColor1,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),
          [AppBar(
            title: "On AIR".text.xl4.bold.white.make().shimmer(
                primaryColor: Vx.purple300, secondaryColor: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(100.0).p16(),
          10.heightBox,
          VxSwiper.builder(
            itemCount: sugg.length,
            height: 50.0,
            viewportFraction: 0.35,
            autoPlay: true,
            autoPlayAnimationDuration: 3.seconds,
            autoPlayCurve: Curves.linear,
            enableInfiniteScroll: true,
            itemBuilder: (context, index) {
              final s = sugg[index];
              return Chip(
                label: s.text.make(),
                backgroundColor: Vx.randomColor,
              );
            },
          )
          ].vStack(alignment: MainAxisAlignment.start),
        30.heightBox,
          radios!=null?VxSwiper.builder(
            itemCount: radios.length,
            aspectRatio: 1.0,
            enlargeCenterPage: true,
            onPageChanged: (index){
              final colorHex = radios[index].color;
              _selectedRadio = radios[index];
              _selectedColor = Color(int.tryParse(colorHex));
              setState(() {

              });
            },
            itemBuilder: (context, index) {
              final rad = radios[index];
              return VxBox(
                      child: ZStack(
                [
                  Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: VxBox(
                              child: rad.category.text.uppercase.white
                                  .make()
                                  .px16())
                          .height(40.0)
                          .black
                          .alignCenter
                          .withRounded(value: 10.0)
                          .make()),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: VStack(
                      [
                        rad.name.text.xl3.white.bold.make(),
                        5.heightBox,
                        rad.tagline.text.sm.white.bold.make(),
                      ],
                      crossAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Center(
                      child: VStack([
                        Center(
                          child: Icon(
                            CupertinoIcons.play_circle,
                            color: Colors.white,
                          ),
                        ),
                        10.heightBox,
                        Center(child: "Double Tap To Play".text.gray300.make()),
                      ]),
                    ),
                  )
                ],
              ))
                  .clip(Clip.antiAlias)
                  .bgImage(DecorationImage(
                      image: NetworkImage(rad.image),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3), BlendMode.darken)))
                  .border(color: Colors.black, width: 3.0)
                  .withRounded(value: 60.0)
                  .make()
                  .onInkDoubleTap(() {
                    playMusic(rad.url);
              })
                  .p16();
            },
          ).centered():Center(child:CircularProgressIndicator(backgroundColor: Colors.white,)),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if(_isPlaying)
                "Playing Now - ${_selectedRadio.name} FM".text.white.makeCentered(),
              Icon(
              _isPlaying?CupertinoIcons.stop_circle
                  :CupertinoIcons.play_circle,
              color: Colors.white,
              size: 50.0,
            ).onInkTap(() {
              if(_isPlaying){
                _audioPlayer.stop();
              }
              else{
                playMusic(_selectedRadio.url);
              }
              })].vStack(),
          ).pOnly(bottom: context.percentHeight * 12),

          Align(
            alignment: Alignment.bottomCenter,
            child: "DevCafe".text.xl2.white.make().shimmer(
                primaryColor: Vx.purple300, secondaryColor: Colors.white),
          ).pOnly(bottom: context.percentHeight * 3),

        ],
        fit: StackFit.expand,
      ),
    );
  }
}
