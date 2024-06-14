namespace :admin do
  task create_data_schemas: :environment do
    sacraments = {
      key: "sacraments",
      title: "Ngày Bí Tích",
      entity: "Person",
      weight: 0,
      fields: [
        {
          field_name: "baptism_date",
          field_type: "date_field",
          label: "Ngày Rửa Tội"
        },
        {
          field_name: "baptism_place",
          field_type: "text_field",
          label: "Nơi Rửa Tội"
        },
        {
          field_name: "communion_date",
          field_type: "date_field",
          label: "Ngày Rước Lễ"
        },
        {
          field_name: "communion_place",
          field_type: "text_field",
          label: "Nơi Rước Lễ"
        },
        {
          field_name: "confirmation_date",
          field_type: "date_field",
          label: "Ngày Thêm Sức"
        },
        {
          field_name: "confirmation_place",
          field_type: "text_field",
          label: "Nơi Thêm Sức"
        },
        {
          field_name: "declaration_date",
          field_type: "date_field",
          label: "Ngày Tuyên Hứa"
        },
        {
          field_name: "declaration_place",
          field_type: "text_field",
          label: "Nơi Tuyên Hứa"
        }
      ]
    }

    parents_info = {
      key: "parents_info",
      title: "Thông Tin Phụ Huynh",
      entity: "Person",
      weight: 1,
      fields: [
        {
          field_name: "father_christian_name",
          field_type: "text_field",
          label: "Tên Thánh Cha"
        },
        {
          field_name: "father_name",
          field_type: "text_field",
          label: "Họ và Tên Cha"
        },
        {
          field_name: "father_phone",
          field_type: "text_field",
          label: "Số Điện Thoại Cha"
        },
        {
          field_name: "mother_christian_name",
          field_type: "text_field",
          label: "Tên Thánh Mẹ"
        },
        {
          field_name: "mother_name",
          field_type: "text_field",
          label: "Họ và Tên Mẹ"
        },
        {
          field_name: "mother_phone",
          field_type: "text_field",
          label: "Số Điện Thoại Mẹ"
        }
      ]
    }

    additional_info = {
      key: "additional_info",
      title: "Thông Tin Phụ",
      entity: "Person",
      weight: 2,
      fields: [
        {
          field_name: "named_date",
          field_type: "text_field",
          label: "Bổn Mạng"
        },
        {
          field_name: "occupation",
          field_type: "text_field",
          label: "Nghề Nghiệp"
        }
      ]
    }

    [sacraments, parents_info, additional_info].each { |schema| DataSchema.create(schema) }
  end
end