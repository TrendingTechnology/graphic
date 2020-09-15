import 'package:meta/meta.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/coord/base.dart';

import 'category/string.dart';
import 'identity/string.dart';
import 'linear/num.dart';
import 'ordinal/date_time.dart';

enum ScaleType {
  ident,
  cat,
  time,
  number,
}

abstract class Scale<V, D> extends Props<ScaleType> {
  void complete(List<D> data, CoordComponent coord) {}
}

abstract class ScaleState<V, D> with TypedMap {
  String Function(V) get formatter => this['formatter'] as String Function(V);
  set formatter(String Function(V) value) => this['formatter'] = value;

  List<double> get range => this['range'] as List<double>;
  set range(List<double> value) => this['range'] = value;

  String get alias => this['alias'] as String;
  set alias(String value) => this['alias'] = value;

  int get tickCount => this['tickCount'] as int;
  set tickCount(int value) => this['tickCount'] = value;

  List<V> get ticks => this['ticks'] as List<V>;
  set ticks(List<V> value) => this['ticks'] = value;

  V Function(D) get accessor => this['accessor'] as V Function(D);
  set accessor(V Function(D) value) => this['accessor'] = value;
}

abstract class ScaleComponent<S extends ScaleState<V, D>, V, D> extends Component<S> {
  static ScaleComponent create<V, D>(Scale<V, D> props) {
    switch (props.type) {
      case ScaleType.ident:
        return StringIdentityScaleComponent<D>(props as IdentScale<D>);
      case ScaleType.cat:
        return StringCategoryScaleComponent<D>(props as CatScale<D>);
      case ScaleType.time:
        return DateTimeOrdinalScaleComponent<D>(props as TimeScale<D>);
      case ScaleType.number:
        return NumLinearScaleComponent<D>(props as NumScale<D>);
      default: return null;
    }
  }

  ScaleComponent([Scale<V, D> props]) : super(props) {
    assign();
  }

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..range = [0, 1]
      ..formatter = (v) => v?.toString();
  }

  @protected
  List<V> getAutoTicks();

  void setProps(Props<ScaleType> props) {
    resetState();
    state.mix(props);
    assign();
  }

  // subclass must assign ticks.
  @protected
  void assign();

  double scale(V value);

  V invert(double scaled);

  String getText(V value) => state.formatter(value);

  double get origin => 0;
}
