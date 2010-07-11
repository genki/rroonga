# Copyright (C) 2010  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License version 2.1 as published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

class PaginationTest < Test::Unit::TestCase
  include GroongaTestUtils

  setup :setup_database

  setup
  def setup_data
    Groonga::Schema.define do |schema|
      schema.create_table("Users",
                          :type => :hash,
                          :key_type => "ShortText") do |table|
        table.uint32(:number)
      end
    end
    @users = context["Users"]
    150.times do |i|
      @users.add("user#{i + 1}", :number => i + 1)
    end
  end

  def test_default
    assert_paginate({
                      :current_page => 1,
                      :page_size => 10,
                      :n_pages => 15,
                      :n_records => 150,
                      :record_range_in_page => 1..10,
                      :have_previous_page? => false,
                      :previous_page => nil,
                      :have_next_page? => true,
                      :next_page => 2,
                    })
  end

  def test_page
    assert_paginate({
                      :current_page => 6,
                      :page_size => 10,
                      :n_pages => 15,
                      :n_records => 150,
                      :record_range_in_page => 51..60,
                      :have_previous_page? => true,
                      :previous_page => 5,
                      :have_next_page? => true,
                      :next_page => 7,
                    },
                    :page => 6)
  end

  def test_max_page
    assert_paginate({
                      :current_page => 15,
                      :page_size => 10,
                      :n_pages => 15,
                      :n_records => 150,
                      :record_range_in_page => 141..150,
                      :have_previous_page? => true,
                      :previous_page => 14,
                      :have_next_page? => false,
                      :next_page => nil,
                    },
                    :page => 15)
  end

  def test_too_large_page
    assert_raise(Groonga::TooLargePage) do
      assert_paginate({},
                      :page => 16)
    end
  end

  def test_zero_page
    assert_raise(Groonga::TooSmallPage) do
      assert_paginate({},
                      :page => 0)
    end
  end

  def test_negative_page
    assert_raise(Groonga::TooSmallPage) do
      assert_paginate({},
                      :page => -1)
    end
  end

  def test_size
    assert_paginate({
                      :current_page => 1,
                      :page_size => 7,
                      :n_pages => 22,
                      :n_records => 150,
                      :record_range_in_page => 1..7,
                      :have_previous_page? => false,
                      :previous_page => nil,
                      :have_next_page? => true,
                      :next_page => 2,
                    },
                    :size => 7)
  end

  def test_max_size
    assert_paginate({
                      :current_page => 1,
                      :page_size => 150,
                      :n_pages => 1,
                      :n_records => 150,
                      :record_range_in_page => 1..150,
                      :have_previous_page? => false,
                      :previous_page => nil,
                      :have_next_page? => false,
                      :next_page => nil,
                    },
                    :size => 150)
  end

  def test_too_large_size
    assert_raise(Groonga::TooLargePageSize) do
      assert_paginate({},
                      :size => 151)
    end
  end

  def test_zero_size
    assert_raise(Groonga::TooSmallPageSize) do
      assert_paginate({},
                      :size => 0)
    end
  end

  def test_negative_size
    assert_raise(Groonga::TooSmallPageSize) do
      assert_paginate({},
                      :size => -1)
    end
  end

  private
  def assert_paginate(expected, options={})
    users = @users.paginate([["number"]], options)
    expected[:keys] ||= expected[:record_range_in_page].collect {|i| "user#{i}"}
    assert_equal(expected,
                 :current_page => users.current_page,
                 :page_size => users.page_size,
                 :n_pages => users.n_pages,
                 :n_records => users.n_records,
                 :record_range_in_page => users.record_range_in_page,
                 :previous_page => users.previous_page,
                 :have_previous_page? => users.have_previous_page?,
                 :next_page => users.next_page,
                 :have_next_page? => users.have_next_page?,
                 :keys => users.collect(&:key))
  end
end
