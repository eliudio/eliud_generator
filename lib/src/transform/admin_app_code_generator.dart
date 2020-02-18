import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

const String _imports = """
import 'package:eliud_model/shared/repository_singleton.dart';
import 'package:eliud_model/shared/action.model.dart';
import 'package:eliud_model/shared/rgb.model.dart';
import 'package:eliud_model/shared/icon.model.dart';

import 'package:eliud_model/model/page.model.dart';
import 'package:eliud_model/model/app_bar.model.dart';
import 'package:eliud_model/model/body_component.model.dart';
import 'package:eliud_model/model/drawer.model.dart';
import 'package:eliud_model/model/menu_item.model.dart';
import 'package:eliud_model/model/popup_menu.model.dart';
import 'package:eliud_model/model/home_menu.model.dart';

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
const String _headerAdminMenu = """
  PopupMenuModel _adminMenu() {
    List<MenuItemModel> menuItems = List<MenuItemModel>();
""";

const String _menuItem = """
    menuItems.add(
      MenuItemModel(
        text: "\${id}s",
        description: "\${id}s",
        icon: IconModel(codePoint: 0xe88a, fontFamily: "MaterialIcons"),
        action: GotoPage(pageID: "\${capsid}SPAGE"))
    );

""";

const String _footerAdminMenu = """
    menuItems.add(
      MenuItemModel(
        text: "Logout",
        description: "Logout",
        icon: IconModel(codePoint: 0xe88a, fontFamily: "MaterialIcons"),
        action: InternalAction(internalActionEnum: InternalActionEnum.Logout)
      ));
    PopupMenuModel menu = PopupMenuModel(
      documentID: "ADMIN_POPUP_MENU_1",
      name: "Admin menu",
      menuItems: menuItems,
      menuItemColor: menuItemColor,
      selectedMenuItemColor: selectedMenuItemColor,
      backgroundColor: backgroundColor,
    );
    return menu;
  }

  Future<PopupMenuModel> _setupMenu() {
    return RepositorySingleton.popupMenuRepository.add(_adminMenu());
  }

""";

// Page
const String _page = """
  PageModel _\${lid}sPages() {
    List<BodyComponentModel> components = List();
    components.add(BodyComponentModel(
        componentName: "internalWidgets", componentId: "\${lid}s"));
    PageModel page = PageModel(
        documentID: "\${capsid}SPAGE",
        readAccess: PageAccess.admin,
        title: "\${id}s",
        drawer: _drawer,
        appBar: _appBar,
        homeMenu: _homeMenu,
        bodyComponents: components,
        container: PageContainerType.OnlyFirstComponent);
    return page;
  }

""";

// _setupAdminPages
const String _setupAdminPagesHeader = """
  Future<void> _setupAdminPages() {
""";

const String _setupAdminPagesFirstPage = """
    return RepositorySingleton.pageRepository.add(_\${lid}sPages())
""";

const String _setupAdminPagesOtherPages = """
        .then((_) => RepositorySingleton.pageRepository.add(_\${lid}sPages()))
""";

const String _setupAdminPagesFooter = """
    ;
  }
""";

// run
const String _headerRun = """
  Future<PopupMenuModel> run() async {
    return await RepositorySingleton.imageRepository.deleteAll()
""";

const String _footerOther = """
        .then((_) => RepositorySingleton.\${lid}Repository.deleteAll())
""";

const String _footerRun = """
        .then((_) => _setupAdminPages())
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

    // Menu
    codeBuffer.writeln(process(_headerAdminMenu));
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateList) && (!spec.modelSpecification.generate.generateEmbeddedComponent)) {
        codeBuffer.writeln(process(_menuItem, parameters: <String, String>{
          '\${id}': spec.modelSpecification.id,
          '\${capsid}': allUpperCase(spec.modelSpecification.id)
        }));
      }
    });
    codeBuffer.writeln(process(_footerAdminMenu));

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
