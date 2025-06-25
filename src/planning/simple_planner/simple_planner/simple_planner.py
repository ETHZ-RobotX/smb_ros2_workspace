import rclpy
from rclpy.node import Node
from geometry_msgs.msg import PointStamped


class SimplePlanner(Node):
    def __init__(self):
        super().__init__('simple_planner')
        
        # Create publisher for PointStamped messages
        self.publisher_ = self.create_publisher(PointStamped, '/way_point', 10)
        
        # Create timer to publish at 1 Hz
        # self.timer = self.create_timer(1.0, self.publish_waypoint)
        self.get_logger().info('Simple planner node started, publishing to /way_point')
        self.publish_waypoint()
        
    
    def publish_waypoint(self):
        msg = PointStamped()
        msg.header.stamp = self.get_clock().now().to_msg()
        msg.header.frame_id = 'map'  # or 'base_link' depending on your needs
        
        # Hardcoded waypoint coordinates
        msg.point.x = 2.0
        msg.point.y = 0.0
        msg.point.z = 0.0
        msg.point
        self.publisher_.publish(msg)
        self.publisher_.publish(msg)

def main(args=None):
    rclpy.init(args=args)
    simple_planner = SimplePlanner()
    
    try:
        rclpy.spin(simple_planner)
    except KeyboardInterrupt:
        pass
    finally:
        simple_planner.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    SimplePlanner.main()