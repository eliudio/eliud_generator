import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator_multi.dart';

const String _imports = """
import 'package:eliud_model/shared/abstract_repository_singleton.dart';
import 'package:eliud_model/shared/action_model.dart';
import 'package:eliud_model/shared/rgb_model.dart';
import 'package:eliud_model/shared/icon_model.dart';
import 'package:eliud_model/shared/grid_view_type_model.dart';
import 'package:eliud_model/model/menu_def_model.dart';

import 'package:eliud_model/model/page_model.dart';
import 'package:eliud_model/model/app_bar_model.dart';
import 'package:eliud_model/model/body_component_model.dart';
import 'package:eliud_model/model/drawer_model.dart';
import 'package:eliud_model/model/menu_item_model.dart';
import 'package:eliud_model/model/home_menu_model.dart';
import 'package:eliud_model/shared/tile_type_model.dart';

""";

const String _header = """
class AdminApp {
  final String appID;
  final DrawerModel _drawer;
  final DrawerModel _endDrawer;
  final AppBarModel _appBar;
  final HomeMenuModel _homeMenu;
  final RgbModel menuItemColor;
  final RgbModel selectedMenuItemColor;
  final RgbModel backgroundColor;
  
  AdminApp(this.appID, this._drawer, this._endDrawer, this._appBar, this._homeMenu, this.menuItemColor, this.selectedMenuItemColor, this.backgroundColor);

""";

// Admin menu
const String _headerAdminMenuDef = """
  static MenuDefModel _adminMenuDef(String appID) {
    List<MenuItemModel> menuItems = List<MenuItemModel>();
""";

const String _menuItemDef = """
    menuItems.add(
      MenuItemModel(
        documentID: "\${id}s",
        text: "\${id}s",
        description: "\${id}s",
        icon: IconModel(codePoint: 0xe88a, fontFamily: "MaterialIcons"),
        action: GotoPage(pageID: "\${lowid}spage"))
    );

""";

const String _footerAdminMenuDef = """
    MenuDefModel menu = MenuDefModel(
      admin: true,
      documentID: "ADMIN_MENU_DEF_1",
      name: "Menu Definition 1",
      menuItems: menuItems
    );
    return menu;
  }

  static Future<MenuDefModel> _setupMenuDef(String appID) {
    return AbstractRepositorySingleton.singleton.menuDefRepository().add(_adminMenuDef(appID));
  }

""";


// Page
const String _page = """
  PageModel _\${lid}sPages() {
    TileTypeModel tileType = new TileExtent(crossAxisCellCount: 1, mainCrossAxisExtentType: MainCrossAxisExtentType.AxisRatio, mainCrossAxisExtentRatio: 1.0);
    List<BodyComponentModel> components = List();
    components.add(BodyComponentModel(
      documentID: "internalWidget-\${lid}s", componentName: "internalWidgets", componentId: "\${lid}s", tileType: tileType));
    PageModel page = PageModel(
        admin: true,
        documentID: "\${lowid}spage",
        readAccess: PageAccess.admin,
        title: "\${id}s",
        drawer: _drawer,
        endDrawer: _endDrawer,
        appBar: _appBar,
        homeMenu: _homeMenu,
        bodyComponents: components,
        scrollDirection: PageScrollDirection.Vertical,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        gridViewType: StaggeredGridViewExtent(maxCrossAxisExtentType: MaxCrossAxisExtentType.AxisRatio, maxCrossAxisExtentRatio: 1.0));
    return page;
  }

""";

// _setupAdminPages
const String _setupAdminPagesHeader = """
  Future<void> _setupAdminPages() {
""";

const String _setupAdminPagesFirstPage = """
    return AbstractRepositorySingleton.singleton.pageRepository().add(_\${lid}sPages())
""";

const String _setupAdminPagesOtherPages = """
        .then((_) => AbstractRepositorySingleton.singleton.pageRepository().add(_\${lid}sPages()))
""";

const String _setupAdminPagesFooter = """
    ;
  }
""";

// run
const String _headerRun = """
  static Future<void> deleteAll(String appID) async {
    return await AbstractRepositorySingleton.singleton.imageRepository().deleteAll()
""";

const String _footerOther = """
        .then((_) => AbstractRepositorySingleton.singleton.\${lid}Repository().deleteAll())
""";

/*
const String _footerOther = """
        .then((_) => AbstractRepositorySingleton.singleton.\${lid}Repository().deleteAll(appID))
""";

const String _footerOtherWithoutAppID = """
        .then((_) => AbstractRepositorySingleton.singleton.\${lid}Repository().deleteAll())
""";

*/
const String _footerApp = """
        .then((_) => AbstractRepositorySingleton.singleton.appRepository().get(appID))
        .then((appModel) {
          if (appModel != null) return AbstractRepositorySingleton.singleton.appRepository().delete(appModel);
          return Future.value();
        })
""";

const String _footerRun = """
    ;
  }

  static Future<MenuDefModel> menu(String appID) async {
    return _setupMenuDef(appID);
  }

  Future<void> run() async {
    return _setupAdminPages();
  }

""";

// footer
const String _footer = """
}
""";

class AdminAppCodeGenerator extends CodeGeneratorMulti {
  AdminAppCodeGenerator(String fileName) : super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    codeBuffer.writeln(process(_imports));
    codeBuffer.writeln(process(_header));

    // MenuDef
    codeBuffer.writeln(process(_headerAdminMenuDef));
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateList) && (!spec.modelSpecification.generate.generateEmbeddedComponent)) {
        codeBuffer.writeln(process(_menuItemDef, parameters: <String, String>{
          '\${id}': spec.modelSpecification.id,
          '\${lowid}': allLowerCase(spec.modelSpecification.id)
        }));
      }
    });
    codeBuffer.writeln(process(_footerAdminMenuDef));

    // Pages
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateList) && (!spec.modelSpecification.generate.generateEmbeddedComponent)) {
        codeBuffer.writeln(process(_page, parameters: <String, String>{
          '\${id}': spec.modelSpecification.id,
          '\${lid}': firstLowerCase(spec.modelSpecification.id),
          '\${lowid}': allLowerCase(spec.modelSpecification.id)
        }));
      }
    });

    // _setupAdminPages
    codeBuffer.writeln(process(_setupAdminPagesHeader));
    bool first = true;
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateList) && (!spec.modelSpecification.generate.generateEmbeddedComponent)) {
        if (first)
          codeBuffer.writeln(process(_setupAdminPagesFirstPage, parameters: <String, String>{
            '\${id}': spec.modelSpecification.id,
            '\${lid}': firstLowerCase(spec.modelSpecification.id),
            '\${lowid}': allLowerCase(spec.modelSpecification.id)
          }));
        else
          codeBuffer.writeln(process(_setupAdminPagesOtherPages, parameters: <String, String>{
            '\${id}': spec.modelSpecification.id,
            '\${lid}': firstLowerCase(spec.modelSpecification.id),
            '\${lowid}': allLowerCase(spec.modelSpecification.id)
          }));
        first = false;
      }
    });
    codeBuffer.writeln(process(_setupAdminPagesFooter));

    codeBuffer.write(process(_headerRun));

    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository)) {
        Map<String, String> parameters = <String, String>{ '\${lid}': firstLowerCase(spec.modelSpecification.id) };
        if (spec.modelSpecification.id != "Member") {
          if (spec.modelSpecification.id == "App") {
            codeBuffer.write(process(_footerApp, parameters: parameters));
          } else {
            codeBuffer.write(process(_footerOther, parameters: parameters));
          }
        }
      }
    });
    codeBuffer.writeln(process(_footerRun));

    codeBuffer.writeln(process(_footer));

    return codeBuffer.toString();
  }
}
