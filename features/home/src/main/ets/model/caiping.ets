import { CourseSchedule } from '@feature/schedule'
/*
 * Copyright (c) 2024. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
 * Morbi non lorem porttitor neque feugiat blandit. Ut vitae ipsum eget quam lacinia accumsan.
 * Etiam sed turpis ac ipsum condimentum fringilla. Maecenas magna.
 * Proin dapibus sapien vel ante. Aliquam erat volutpat. Pellentesque sagittis ligula eget metus.
 * Vestibulum commodo. Ut rhoncus gravida arcu.
 */
import { LazyDataSource } from '@ohos/utils'
import { CampusNews } from '../components/CampusNews';
import { News, NewsInt } from './News';

const tableId = 'item.TableId';
const scheduleId = 'item.ScheduleId';
const weekRanges = 'item.WeekRanges';
const weekDay = 'item.WeekDay';
const startSession = 'item.StartSession'
const endSession = 'item.EndSession'
const place = 'item.Place';
const courseId = 'item.ClassId';

export const cai: Array<CourseSchedule>  = [
  new CourseSchedule(weekRanges as string, tableId as string,
    courseId as string, '西红柿炒鸡蛋', scheduleId as string,
    weekDay as string, 0, 0, '10 min', '西红柿、鸡蛋'),
  new CourseSchedule(weekRanges as string, tableId as string,
    courseId as string, '红烧茄子', scheduleId as string,
    weekDay as string, 0, 0, '30 min', '茄子')
]

export const store: Array<NewsInt> = [
  {
    TITLE: '香蕉',
    DATE: '12-25',
    HREF: 'www.bilibili.com'
  },
  {
    TITLE: '黄瓜',
    DATE: '12-25',
    HREF: 'www.bilibili.com'
  },
  {
    TITLE: '茄子',
    DATE: '12-25',
    HREF: 'www.bilibili.com'
  },
  {
    TITLE: '西红柿',
    DATE: '12-25',
    HREF: 'www.bilibili.com'
  },
  {
    TITLE: '苹果',
    DATE: '12-25',
    HREF: 'www.bilibili.com'
  },
  {
    TITLE: '香蕉',
    DATE: '12-25',
    HREF: 'www.bilibili.com'
  },
  {
    TITLE: '香蕉',
    DATE: '12-25',
    HREF: 'www.bilibili.com'
  },
  {
    TITLE: '香蕉',
    DATE: '12-25',
    HREF: 'www.bilibili.com'
  }
]