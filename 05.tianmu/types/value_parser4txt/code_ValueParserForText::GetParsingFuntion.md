#1.ValueParserForText::GetParsingFuntion

```cpp
ValueParserForText::GetParsingFuntion
--switch (at.Type()) {
      case common::ColumnType::NUM:
        return std::bind<common::ErrorCode>(&ParseDecimal, std::placeholders::_1, std::placeholders::_2, at.Precision(),
                                            at.Scale());
      case common::ColumnType::REAL:
      case common::ColumnType::FLOAT:
      case common::ColumnType::BYTEINT:
      case common::ColumnType::SMALLINT:
      case common::ColumnType::MEDIUMINT:
      case common::ColumnType::INT:
        return std::bind<common::ErrorCode>(&ParseNumeric, std::placeholders::_1, std::placeholders::_2, at.Type(),
                                            at.GetUnsignedFlag());
      case common::ColumnType::BIGINT:
        return &ParseBigIntAdapter;
      case common::ColumnType::BIT:
        return &ParseBitAdapter;
      case common::ColumnType::DATE:
      case common::ColumnType::TIME:
      case common::ColumnType::YEAR:
      case common::ColumnType::DATETIME:
      case common::ColumnType::TIMESTAMP:
        return std::bind<common::ErrorCode>(&ParseDateTimeAdapter, std::placeholders::_1, std::placeholders::_2,
                                            at.Type());
      default:
        TIANMU_ERROR("type not supported:" + std::to_string(static_cast<unsigned char>(at.Type())));
        break;
    }

```