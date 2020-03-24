import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

const String _imports = """
import 'package:eliud_model/shared/abstract_repository_singleton.dart';
import 'package:eliud_model/shared/action.model.dart';
import 'package:eliud_model/shared/rgb.model.dart';
import 'package:eliud_model/shared/icon.model.dart';
import 'package:eliud_model/shared/grid_view_type.model.dart';
import 'package:eliud_model/model/menu_def.model.dart';

import 'package:eliud_model/model/page.model.dart';
import 'package:eliud_model/model/app_bar.model.dart';
import 'package:eliud_model/model/body_component.model.dart';
import 'package:eliud_model/model/drawer.model.dart';
import 'package:eliud_model/model/menu_item.model.dart';
import 'package:eliud_model/model/popup_menu.model.dart';
import 'package:eliud_model/model/home_menu.model.dart';
import 'package:eliud_model/shared/tile_type.model.dart';

""";

const String _header = """
class SetupAdmin {
  final DrawerModel _drawer;
  final AppBarModel _appBar;
  final HomeMenuModel _homeMenu;
  final RgbModel menuItemColor;
  final RgbModel selectedMenuItemColor;
  final RgbModel backgroundColor;

  SetupAdmin(this._drawer, this._appBar, this._homeMenu, this.menuItemColor, this.selectedMenuItemColor, this.backgroundColor);

""";

// Admin menu
const String _headerAdminMenuDef = """
  MenuDefModel _adminMenuDef() {
    List<MenuItemModel> menuItems = List<MenuItemModel>();
""";

const String _menuItemDef = """
    menuItems.add(
      MenuItemModel(
        documentID: "\${id}s",
        text: "\${id}s",
        description: "\${id}s",
        icon: IconModel(codePoint: 0xe88a, fontFamily: "MaterialIcons"),
        action: GotoPage(pageID: "\${capsid}SPAGE"))
    );

""";

const String _footerAdminMenuDef = """
    menuItems.add(
      MenuItemModel(
        documentID: "Logout",
        text: "Logout",
        description: "Logout",
        icon: IconModel(codePoint: 0xe88a, fontFamily: "MaterialIcons"),
        action: InternalAction(internalActionEnum: InternalActionEnum.Logout)
      ));
      
    MenuDefModel menu = MenuDefModel(
      documentID: "ADMIN_MENU_DEF_1",
      name: "Menu Definition 1",
      menuItems: menuItems
    );
    return menu;
  }

  Future<MenuDefModel> _setupMenuDef() {
    return AbstractRepositorySingleton.singleton.menuDefRepository().add(_adminMenuDef());
  }

""";

const String _adminMenu = """
  PopupMenuModel _adminMenu() {
    return PopupMenuModel(
      documentID: "ADMIN_POPUP_MENU_1",
      name: "Admin menu",
      menuDef: _adminMenuDef(),
      menuItemColor: menuItemColor,
      selectedMenuItemColor: selectedMenuItemColor,
      backgroundColor: backgroundColor,
    );
  }

  Future<PopupMenuModel> _setupMenu() {
    return AbstractRepositorySingleton.singleton.popupMenuRepository().add(_adminMenu());
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
        documentID: "\${capsid}SPAGE",
        readAccess: PageAccess.admin,
        title: "\${id}s",
        drawer: _drawer,
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
  Future<PopupMenuModel> run() async {
    return await AbstractRepositorySingleton.singleton.imageRepository().deleteAll()
""";

const String _footerOther = """
        .then((_) => AbstractRepositorySingleton.singleton.\${lid}Repository().deleteAll())
""";

const String _footerRun = """
        .then((_) => _setupAdminPages())
        .then((_) => _setupMenuDef())
        .then((_) => _setupMenu());
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
          '\${capsid}': allUpperCase(spec.modelSpecification.id)
        }));
      }
    });
    codeBuffer.writeln(process(_footerAdminMenuDef));

    // MenuDef
    codeBuffer.writeln(process(_adminMenu));

    // Pages
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateList) && (!spec.modelSpecification.generate.generateEmbeddedComponent)) {
        codeBuffer.writeln(process(_page, parameters: <String, String>{
          '\${id}': spec.modelSpecification.id,
          '\${lid}': firstLowerCase(spec.modelSpecification.id),
          '\${capsid}': allUpperCase(spec.modelSpecification.id)
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
            '\${capsid}': allUpperCase(spec.modelSpecification.id)
          }));
        else
          codeBuffer.writeln(process(_setupAdminPagesOtherPages, parameters: <String, String>{
            '\${id}': spec.modelSpecification.id,
            '\${lid}': firstLowerCase(spec.modelSpecification.id),
            '\${capsid}': allUpperCase(spec.modelSpecification.id)
          }));
        first = false;
      }
    });
    codeBuffer.writeln(process(_setupAdminPagesFooter));

    // run
    codeBuffer.writeln(process(_headerRun));
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository)) {
        codeBuffer.writeln(process(_footerOther, parameters: <String, String>{ '\${lid}': firstLowerCase(spec.modelSpecification.id) }));
      }
    });
    codeBuffer.writeln(process(_footerRun));

    codeBuffer.writeln(process(_footer));

    return codeBuffer.toString();
  }
}
